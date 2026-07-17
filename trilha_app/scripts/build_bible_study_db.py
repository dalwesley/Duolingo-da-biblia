#!/usr/bin/env python3
"""Gera assets/data/bible_study.sqlite (Strong + morfologia + refs cruzadas).

Fontes (CC BY 4.0):
  - STEPBible / Tyndale House — léxico TBESH/TBESG + textos TAHOT/TAGNT
  - openbible.info — cross references

Uso:
  python3 scripts/build_bible_study_db.py
"""

from __future__ import annotations

import html
import re
import sqlite3
import sys
import urllib.request
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "assets" / "data" / "bible_study.sqlite"
CACHE = Path("/tmp/trilha_bible_study_src")

STEP = "https://raw.githubusercontent.com/STEPBible/STEPBible-Data/master"
OPENBIBLE = (
    "https://raw.githubusercontent.com/scrollmapper/bible_databases/master/"
    "sources/extras/cross_references.txt"
)

FILES = {
    "tbesh": f"{STEP}/Lexicons/TBESH%20-%20Translators%20Brief%20lexicon%20of%20Extended%20Strongs%20for%20Hebrew%20-%20STEPBible.org%20CC%20BY.txt",
    "tbesg": f"{STEP}/Lexicons/TBESG%20-%20Translators%20Brief%20lexicon%20of%20Extended%20Strongs%20for%20Greek%20-%20STEPBible.org%20CC%20BY.txt",
    "tahot1": f"{STEP}/Translators%20Amalgamated%20OT%2BNT/TAHOT%20Gen-Deu%20-%20Translators%20Amalgamated%20Hebrew%20OT%20-%20STEPBible.org%20CC%20BY.txt",
    "tahot2": f"{STEP}/Translators%20Amalgamated%20OT%2BNT/TAHOT%20Jos-Est%20-%20Translators%20Amalgamated%20Hebrew%20OT%20-%20STEPBible.org%20CC%20BY.txt",
    "tahot3": f"{STEP}/Translators%20Amalgamated%20OT%2BNT/TAHOT%20Job-Sng%20-%20Translators%20Amalgamated%20Hebrew%20OT%20-%20STEPBible.org%20CC%20BY.txt",
    "tahot4": f"{STEP}/Translators%20Amalgamated%20OT%2BNT/TAHOT%20Isa-Mal%20-%20Translators%20Amalgamated%20Hebrew%20OT%20-%20STEPBible.org%20CC%20BY.txt",
    "tagnt1": f"{STEP}/Translators%20Amalgamated%20OT%2BNT/TAGNT%20Mat-Jhn%20-%20Translators%20Amalgamated%20Greek%20NT%20-%20STEPBible.org%20CC-BY.txt",
    "tagnt2": f"{STEP}/Translators%20Amalgamated%20OT%2BNT/TAGNT%20Act-Rev%20-%20Translators%20Amalgamated%20Greek%20NT%20-%20STEPBible.org%20CC-BY.txt",
    "xref": OPENBIBLE,
}

# Ordem protestante = bible_tb.json (índice 0-based no app).
STEP_BOOKS = [
    "Gen", "Exo", "Lev", "Num", "Deu", "Jos", "Jdg", "Rut",
    "1Sa", "2Sa", "1Ki", "2Ki", "1Ch", "2Ch", "Ezr", "Neh", "Est",
    "Job", "Psa", "Pro", "Ecc", "Sng", "Isa", "Jer", "Lam", "Ezk", "Dan",
    "Hos", "Joe", "Amo", "Oba", "Jon", "Mic", "Nah", "Hab", "Zep", "Hag", "Zec", "Mal",
    "Mat", "Mrk", "Luk", "Jhn", "Act", "Rom", "1Co", "2Co", "Gal", "Eph",
    "Php", "Col", "1Th", "2Th", "1Ti", "2Ti", "Tit", "Phm", "Heb", "Jas",
    "1Pe", "2Pe", "1Jn", "2Jn", "3Jn", "Jud", "Rev",
]
BOOK_INDEX = {b: i for i, b in enumerate(STEP_BOOKS)}

# openbible.info usa nomes ligeiramente diferentes.
XREF_BOOKS = {
    "Gen": "Gen", "Exod": "Exo", "Lev": "Lev", "Num": "Num", "Deut": "Deu",
    "Josh": "Jos", "Judg": "Jdg", "Ruth": "Rut", "1Sam": "1Sa", "2Sam": "2Sa",
    "1Kgs": "1Ki", "2Kgs": "2Ki", "1Chr": "1Ch", "2Chr": "2Ch",
    "Ezra": "Ezr", "Neh": "Neh", "Esth": "Est", "Job": "Job", "Ps": "Psa",
    "Prov": "Pro", "Eccl": "Ecc", "Song": "Sng", "Isa": "Isa", "Jer": "Jer",
    "Lam": "Lam", "Ezek": "Ezk", "Dan": "Dan", "Hos": "Hos", "Joel": "Joe",
    "Amos": "Amo", "Obad": "Oba", "Jonah": "Jon", "Mic": "Mic", "Nah": "Nah",
    "Hab": "Hab", "Zeph": "Zep", "Hag": "Hag", "Zech": "Zec", "Mal": "Mal",
    "Matt": "Mat", "Mark": "Mrk", "Luke": "Luk", "John": "Jhn", "Acts": "Act",
    "Rom": "Rom", "1Cor": "1Co", "2Cor": "2Co", "Gal": "Gal", "Eph": "Eph",
    "Phil": "Php", "Col": "Col", "1Thess": "1Th", "2Thess": "2Th",
    "1Tim": "1Ti", "2Tim": "2Ti", "Titus": "Tit", "Phlm": "Phm",
    "Heb": "Heb", "Jas": "Jas", "1Pet": "1Pe", "2Pet": "2Pe",
    "1John": "1Jn", "2John": "2Jn", "3John": "3Jn", "Jude": "Jud", "Rev": "Rev",
}

TAG_RE = re.compile(
    r"^([1-3]?[A-Za-z]+)\.(\d+)\.(\d+)#(\d+)=(\S+)\t(.+)$"
)
STRONG_ROOT_RE = re.compile(r"\{?([HG]\d{1,5}[A-Z]?)\}?")
HTML_RE = re.compile(r"<[^>]+>")


def download(name: str, url: str) -> Path:
    CACHE.mkdir(parents=True, exist_ok=True)
    path = CACHE / name
    if path.exists() and path.stat().st_size > 1000:
        print(f"  cache hit {name}")
        return path
    print(f"  baixando {name} …")
    req = urllib.request.Request(url, headers={"User-Agent": "trilha-app-build/1.0"})
    with urllib.request.urlopen(req, timeout=300) as resp, path.open("wb") as out:
        while True:
            chunk = resp.read(1024 * 256)
            if not chunk:
                break
            out.write(chunk)
    print(f"  ok {name} ({path.stat().st_size:,} bytes)")
    return path


def normalize_strong(raw: str) -> str | None:
    raw = raw.strip().upper()
    m = re.match(r"^([HG])0*(\d{1,5})([A-Z]?)$", raw)
    if not m:
        return None
    letter, num, suffix = m.group(1), m.group(2), m.group(3)
    # Prefixos/sufixos H9xxx — manter se forem léxicos úteis; tokens usam root.
    return f"{letter}{int(num):04d}{suffix}"


def base_strong(raw: str) -> str | None:
    """H7225G → H7225 (sem desambiguação)."""
    n = normalize_strong(raw)
    if not n:
        return None
    return re.sub(r"[A-Z]$", "", n) if n[-1:].isalpha() and n[0] in "HG" else n


def strip_html(text: str) -> str:
    text = text.replace("<BR>", "\n").replace("<br>", "\n").replace("<br/>", "\n")
    text = HTML_RE.sub("", text)
    text = html.unescape(text)
    text = re.sub(r"\s+\n", "\n", text)
    text = re.sub(r"[ \t]+", " ", text)
    return text.strip()


def clean_surface(text: str) -> str:
    # Remove marcações de prefixo/sufixo e pontuação cantilada excessiva.
    text = text.replace("/", "").replace("\\", "")
    text = re.sub(r"\s*\([^)]*\)\s*$", "", text)  # grego: palavra (translit) no surface
    return text.strip()


def extract_greek_surface_translit(col: str) -> tuple[str, str]:
    m = re.match(r"^(.+?)\s*\(([^)]+)\)\s*$", col.strip())
    if m:
        return m.group(1).strip(), m.group(2).strip()
    return col.strip(), ""


def parse_lexicon(path: Path, lang: str) -> list[tuple]:
    rows: dict[str, tuple] = {}
    with path.open(encoding="utf-8", errors="replace") as f:
        for line in f:
            if not line or line[0] not in "HG":
                continue
            parts = line.rstrip("\n").split("\t")
            if len(parts) < 7:
                continue
            e_strong = parts[0].strip()
            # Preferir entrada "principal" (dStrong termina com = ou =\t).
            d_field = parts[1] if len(parts) > 1 else ""
            lemma = parts[3].strip() if len(parts) > 3 else ""
            translit = parts[4].strip() if len(parts) > 4 else ""
            morph = parts[5].strip() if len(parts) > 5 else ""
            gloss = parts[6].strip() if len(parts) > 6 else ""
            definition = strip_html(parts[7]) if len(parts) > 7 else ""
            if len(definition) > 600:
                definition = definition[:597] + "…"

            key = base_strong(e_strong) or normalize_strong(e_strong)
            if not key:
                continue
            # Preferir entrada canônica sem letra de desambiguação no eStrong base,
            # ou a primeira vista.
            score = 0
            if "=" in d_field and "Part of" not in d_field and "Name of" not in d_field:
                score += 2
            if re.match(r"^[HG]\d+$", e_strong.upper()) or re.match(
                r"^[HG]\d+G\s*$", e_strong.upper()
            ):
                score += 1
            prev = rows.get(key)
            if prev is None or score >= prev[0]:
                rows[key] = (
                    score,
                    key,
                    lang,
                    lemma.split(",")[0].strip(),
                    translit.split(",")[0].strip(),
                    morph,
                    gloss.split("/")[0].strip()[:80],
                    definition,
                )
    return [v[1:] for v in rows.values()]


def root_from_dstrongs(field: str) -> str | None:
    # Preferir conteúdo entre {}
    braces = re.findall(r"\{([HG][^}]*)\}", field)
    candidates = braces if braces else STRONG_ROOT_RE.findall(field)
    for c in candidates:
        # Ignorar prefixos/sufixos gramaticais H9xxx / G9xxx altos tipicamente morf.
        base = base_strong(c.split("=")[0])
        if not base:
            continue
        num = int(re.sub(r"\D", "", base) or "0")
        if base.startswith("H") and 9000 <= num <= 9999:
            continue
        if base.startswith("G") and 9000 <= num <= 9999:
            continue
        return base
    # fallback: qualquer strong
    for c in STRONG_ROOT_RE.findall(field):
        b = base_strong(c)
        if b:
            return b
    return None


def parse_hebrew_tokens(path: Path, cur: sqlite3.Cursor) -> int:
    count = 0
    batch: list[tuple] = []
    with path.open(encoding="utf-8", errors="replace") as f:
        for line in f:
            m = TAG_RE.match(line)
            if not m:
                continue
            book_s, chap, verse, pos, _typ, rest = m.groups()
            book = BOOK_INDEX.get(book_s)
            if book is None:
                continue
            cols = rest.split("\t")
            if len(cols) < 5:
                continue
            surface = clean_surface(cols[0])
            translit = cols[1].replace("/", "").strip()
            gloss = cols[2].replace("/", " ").strip()
            gloss = re.sub(r"[<>\[\]]", "", gloss)[:60]
            dstrongs = cols[3]
            morph = cols[4].strip()
            strong = root_from_dstrongs(dstrongs)
            if not strong or not surface:
                continue
            batch.append(
                (
                    book,
                    int(chap),
                    int(verse),
                    int(pos),
                    surface,
                    translit,
                    gloss,
                    strong,
                    morph,
                )
            )
            if len(batch) >= 2000:
                cur.executemany(
                    "INSERT OR REPLACE INTO tokens VALUES (?,?,?,?,?,?,?,?,?)",
                    batch,
                )
                count += len(batch)
                batch.clear()
    if batch:
        cur.executemany(
            "INSERT OR REPLACE INTO tokens VALUES (?,?,?,?,?,?,?,?,?)", batch
        )
        count += len(batch)
    return count


def parse_greek_tokens(path: Path, cur: sqlite3.Cursor) -> int:
    count = 0
    batch: list[tuple] = []
    with path.open(encoding="utf-8", errors="replace") as f:
        for line in f:
            m = TAG_RE.match(line)
            if not m:
                continue
            book_s, chap, verse, pos, _typ, rest = m.groups()
            book = BOOK_INDEX.get(book_s)
            if book is None:
                continue
            cols = rest.split("\t")
            if len(cols) < 4:
                continue
            # Greek word-line: surface(translit) | gloss | Gxxxx=morph | lemma=gloss
            surface, translit = extract_greek_surface_translit(cols[0])
            gloss = re.sub(r"[<>\[\]]", "", cols[1]).strip()[:60]
            sg = cols[2]
            sm = re.match(r"^([HG][^\s=]+)=(\S+)", sg)
            if sm:
                strong = base_strong(sm.group(1))
                morph = sm.group(2)
            else:
                strong = root_from_dstrongs(sg)
                morph = ""
            if not strong or not surface:
                continue
            # lemma=gloss column sometimes present
            if not gloss and len(cols) > 3 and "=" in cols[3]:
                gloss = cols[3].split("=", 1)[-1].strip()[:60]
            batch.append(
                (
                    book,
                    int(chap),
                    int(verse),
                    int(pos),
                    surface,
                    translit,
                    gloss,
                    strong,
                    morph,
                )
            )
            if len(batch) >= 2000:
                cur.executemany(
                    "INSERT OR REPLACE INTO tokens VALUES (?,?,?,?,?,?,?,?,?)",
                    batch,
                )
                count += len(batch)
                batch.clear()
    if batch:
        cur.executemany(
            "INSERT OR REPLACE INTO tokens VALUES (?,?,?,?,?,?,?,?,?)", batch
        )
        count += len(batch)
    return count


def parse_xref(path: Path, cur: sqlite3.Cursor) -> int:
    ref_re = re.compile(
        r"^([1-3]?[A-Za-z]+)\.(\d+)\.(\d+)(?:-([1-3]?[A-Za-z]+)\.(\d+)\.(\d+))?$"
    )

    def parse_ref(s: str):
        m = ref_re.match(s.strip())
        if not m:
            return None
        b1, c1, v1, b2, c2, v2 = m.groups()
        step = XREF_BOOKS.get(b1)
        if not step or step not in BOOK_INDEX:
            return None
        book = BOOK_INDEX[step]
        chap, verse = int(c1), int(v1)
        end = None
        if b2:
            step2 = XREF_BOOKS.get(b2)
            if step2 == step and int(c2) == chap:
                end = int(v2)
        return book, chap, verse, end

    # Agrupa e mantém top refs por versículo.
    buckets: dict[tuple[int, int, int], list[tuple[int, int, int, int | None, int]]] = {}
    with path.open(encoding="utf-8", errors="replace") as f:
        next(f, None)  # header
        for line in f:
            parts = line.rstrip("\n").split("\t")
            if len(parts) < 3:
                continue
            try:
                votes = int(parts[2])
            except ValueError:
                continue
            if votes < 8:
                continue
            src = parse_ref(parts[0])
            # destino pode ser range
            dst_raw = parts[1]
            # Gen.1.1 or Prov.8.22-Prov.8.30
            if "-" in dst_raw and re.search(r"[A-Za-z]", dst_raw.split("-")[0]):
                # full range form already in parse_ref if single pattern;
                # openbible uses From-To as second field sometimes as A.B.C-A.B.D
                m = re.match(
                    r"^([1-3]?[A-Za-z]+)\.(\d+)\.(\d+)-([1-3]?[A-Za-z]+)\.(\d+)\.(\d+)$",
                    dst_raw,
                )
                if not m:
                    continue
                b1, c1, v1, b2, c2, v2 = m.groups()
                step = XREF_BOOKS.get(b1)
                if not step or step not in BOOK_INDEX:
                    continue
                if XREF_BOOKS.get(b2) != step or int(c1) != int(c2):
                    # só ranges no mesmo capítulo
                    dst = (BOOK_INDEX[step], int(c1), int(v1), None)
                else:
                    dst = (BOOK_INDEX[step], int(c1), int(v1), int(v2))
            else:
                parsed = parse_ref(dst_raw)
                if not parsed:
                    continue
                dst = parsed
            if not src:
                continue
            key = (src[0], src[1], src[2])
            buckets.setdefault(key, []).append(
                (dst[0], dst[1], dst[2], dst[3], votes)
            )

    count = 0
    batch = []
    for (fb, fc, fv), items in buckets.items():
        items.sort(key=lambda x: -x[4])
        for tb, tc, tv, te, votes in items[:12]:
            batch.append((fb, fc, fv, tb, tc, tv, te, votes))
            if len(batch) >= 3000:
                cur.executemany(
                    "INSERT INTO cross_refs VALUES (?,?,?,?,?,?,?,?)", batch
                )
                count += len(batch)
                batch.clear()
    if batch:
        cur.executemany("INSERT INTO cross_refs VALUES (?,?,?,?,?,?,?,?)", batch)
        count += len(batch)
    return count


def main() -> None:
    print("1) Baixando fontes…")
    paths = {k: download(k, url) for k, url in FILES.items()}

    if OUT.exists():
        OUT.unlink()
    OUT.parent.mkdir(parents=True, exist_ok=True)

    con = sqlite3.connect(OUT)
    cur = con.cursor()
    cur.executescript(
        """
        PRAGMA journal_mode=OFF;
        PRAGMA synchronous=OFF;
        CREATE TABLE meta (key TEXT PRIMARY KEY, value TEXT);
        CREATE TABLE lexicon (
          id TEXT PRIMARY KEY,
          lang TEXT NOT NULL,
          lemma TEXT,
          translit TEXT,
          morph TEXT,
          gloss TEXT,
          definition TEXT
        );
        CREATE TABLE tokens (
          book INTEGER NOT NULL,
          chapter INTEGER NOT NULL,
          verse INTEGER NOT NULL,
          pos INTEGER NOT NULL,
          surface TEXT,
          translit TEXT,
          gloss TEXT,
          strong TEXT NOT NULL,
          morph TEXT,
          PRIMARY KEY (book, chapter, verse, pos)
        );
        CREATE TABLE cross_refs (
          from_book INTEGER,
          from_chapter INTEGER,
          from_verse INTEGER,
          to_book INTEGER,
          to_chapter INTEGER,
          to_verse INTEGER,
          to_verse_end INTEGER,
          votes INTEGER
        );
        """
    )

    print("2) Léxico…")
    he = parse_lexicon(paths["tbesh"], "H")
    gr = parse_lexicon(paths["tbesg"], "G")
    cur.executemany(
        "INSERT OR REPLACE INTO lexicon VALUES (?,?,?,?,?,?,?)", he + gr
    )
    print(f"   {len(he)} hebraico + {len(gr)} grego")

    print("3) Tokens OT…")
    n = 0
    for k in ("tahot1", "tahot2", "tahot3", "tahot4"):
        c = parse_hebrew_tokens(paths[k], cur)
        print(f"   {k}: {c:,}")
        n += c

    print("4) Tokens NT…")
    for k in ("tagnt1", "tagnt2"):
        c = parse_greek_tokens(paths[k], cur)
        print(f"   {k}: {c:,}")
        n += c
    print(f"   total tokens: {n:,}")

    print("5) Referências cruzadas…")
    xc = parse_xref(paths["xref"], cur)
    print(f"   {xc:,} refs")

    print("6) Índices…")
    cur.executescript(
        """
        CREATE INDEX idx_tokens_strong ON tokens(strong);
        CREATE INDEX idx_tokens_verse ON tokens(book, chapter, verse);
        CREATE INDEX idx_xref_from ON cross_refs(from_book, from_chapter, from_verse);
        INSERT INTO meta VALUES ('version', '1');
        INSERT INTO meta VALUES (
          'attribution',
          'Lexical & tagged texts: STEPBible / Tyndale House Cambridge (CC BY 4.0). Cross-refs: openbible.info (CC BY).'
        );
        VACUUM;
        """
    )
    con.commit()
    con.close()
    print(f"Pronto: {OUT} ({OUT.stat().st_size:,} bytes)")
    # Gzip para o asset do app (menor no git / bundle).
    import gzip as gz

    gz_path = OUT.with_suffix(".sqlite.gz")
    with OUT.open("rb") as src, gz.open(gz_path, "wb", compresslevel=9) as dst:
        dst.write(src.read())
    print(f"Gzip: {gz_path} ({gz_path.stat().st_size:,} bytes)")


if __name__ == "__main__":
    try:
        main()
    except Exception as e:
        print("ERRO:", e, file=sys.stderr)
        raise
