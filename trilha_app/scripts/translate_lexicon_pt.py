#!/usr/bin/env python3
"""Traduz gloss + definição do léxico Strong para português (offline no app).

Usa Google Translate via deep-translator, cacheia por texto único.
Requer rede. Retomável.

  .venv-translate/bin/python scripts/translate_lexicon_pt.py
"""

from __future__ import annotations

import gzip
import json
import re
import sqlite3
import sys
import time
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
GZ = ROOT / "assets" / "data" / "bible_study.sqlite.gz"
DB = ROOT / "assets" / "data" / "bible_study.sqlite"
CACHE = ROOT / "scripts" / ".lexicon_pt_cache.json"

SLEEP = 0.25
BATCH_GLOSS = 40  # textos curtos por request
BATCH_DEF = 8


def load_cache() -> dict[str, str]:
    if not CACHE.exists():
        return {}
    raw = json.loads(CACHE.read_text(encoding="utf-8"))
    # Ignora entradas onde "tradução" == original (falhas antigas)
    return {k: v for k, v in raw.items() if v and v != k}


def save_cache(cache: dict[str, str]) -> None:
    CACHE.write_text(
        json.dumps(cache, ensure_ascii=False, separators=(",", ":")),
        encoding="utf-8",
    )


def looks_english(text: str) -> bool:
    t = text.lower()
    # Heurística simples: presença de palavras EN comuns em glossários bíblicos
    markers = (
        " the ", " and ", " of ", " to ", " a ", " in ", " for ",
        "serpent", "father", "god", "lord", "love", "which", "with",
        "from", "unto", "that", "this", "are", "was", "were",
    )
    padded = f" {t} "
    return any(m in padded for m in markers) or bool(re.search(r"\b(to|of|the)\b", t))


def translate_unique(
    translator,
    texts: list[str],
    cache: dict[str, str],
    batch_size: int,
    label: str,
) -> None:
    pending = [t for t in texts if t not in cache]
    print(f"   {label}: {len(pending)} pendentes / {len(texts)} únicos")
    if not pending:
        return

    sep = "\n¦\n"
    for i in range(0, len(pending), batch_size):
        chunk = pending[i : i + batch_size]
        # Truncar defs muito longas
        send = [c if len(c) <= 700 else c[:697] + "…" for c in chunk]
        joined = sep.join(send)
        try:
            out = translator.translate(joined)
            parts = [p.strip() for p in out.split("¦")]
            if len(parts) != len(chunk):
                raise ValueError(f"split {len(parts)}!={len(chunk)}")
            for src, pt in zip(chunk, parts):
                if pt:
                    cache[src] = pt
        except Exception as e:
            print(f"   batch fail @ {i}: {e}; one-by-one")
            for src, s in zip(chunk, send):
                if src in cache:
                    continue
                try:
                    cache[src] = translator.translate(s)
                except Exception as e2:
                    print(f"   skip: {e2}")
                time.sleep(SLEEP)

        if (i // batch_size) % 15 == 0:
            save_cache(cache)
            done = min(i + batch_size, len(pending))
            print(f"   {label} {done}/{len(pending)} · cache {len(cache)}")
        time.sleep(SLEEP)

    save_cache(cache)


def clean_def_for_display(text: str) -> str:
    # Remove ruído acadêmico comum no final
    text = re.sub(r"\s*\(AS\)\s*$", "", text)
    text = re.sub(r"\s*†\s*$", "", text)
    return text.strip()


def main() -> None:
    from deep_translator import GoogleTranslator

    if not GZ.exists():
        raise SystemExit(f"Missing {GZ}")

    print("1) Abrindo DB…")
    if DB.exists():
        DB.unlink()
    DB.write_bytes(gzip.decompress(GZ.read_bytes()))

    con = sqlite3.connect(DB)
    cur = con.cursor()
    rows = cur.execute("SELECT id, gloss, definition FROM lexicon").fetchall()
    used = {
        r[0]
        for r in cur.execute("SELECT DISTINCT strong FROM tokens").fetchall()
    }
    print(f"   lexicon {len(rows)} · strongs usados {len(used)}")

    cache = load_cache()
    print(f"   cache limpo: {len(cache)}")

    # Prioriza entradas usadas no cânon
    glosses: set[str] = set()
    defs: set[str] = set()
    for sid, g, d in rows:
        if sid not in used:
            continue
        g = (g or "").strip()
        d = clean_def_for_display((d or "").strip())
        if g:
            glosses.add(g)
        if d:
            defs.add(d)

    translator = GoogleTranslator(source="en", target="pt")

    print("2) Traduzindo glosses…")
    translate_unique(
        translator, sorted(glosses), cache, BATCH_GLOSS, "gloss"
    )
    print("3) Traduzindo definições…")
    translate_unique(translator, sorted(defs), cache, BATCH_DEF, "def")

    # Também preenche o restante do léxico (não usados) se sobrar tempo —
    # glosses curtos ajudam busca futura
    other_g = set()
    other_d = set()
    for sid, g, d in rows:
        if sid in used:
            continue
        g = (g or "").strip()
        d = clean_def_for_display((d or "").strip())
        if g and g not in cache:
            other_g.add(g)
        if d and d not in cache:
            other_d.add(d)
    if other_g or other_d:
        print("4) Resto do léxico…")
        translate_unique(
            translator, sorted(other_g), cache, BATCH_GLOSS, "gloss+"
        )
        translate_unique(
            translator, sorted(other_d), cache, BATCH_DEF, "def+"
        )

    print("5) Aplicando no SQLite…")
    updates = []
    missing = 0
    for sid, g, d in rows:
        g = (g or "").strip()
        d0 = (d or "").strip()
        d = clean_def_for_display(d0)
        g_pt = cache.get(g, g)
        d_pt = cache.get(d, d0)
        if g and g_pt == g and looks_english(g):
            missing += 1
        updates.append((g_pt, d_pt, sid))

    cur.executemany(
        "UPDATE lexicon SET gloss = ?, definition = ? WHERE id = ?", updates
    )
    print(f"   glosses ainda EN (aprox): {missing}")

    print("6) Atualizando chips (tokens.gloss)…")
    cur.execute(
        """
        UPDATE tokens
        SET gloss = (
          SELECT lexicon.gloss FROM lexicon WHERE lexicon.id = tokens.strong
        )
        WHERE EXISTS (
          SELECT 1 FROM lexicon
          WHERE lexicon.id = tokens.strong
            AND lexicon.gloss IS NOT NULL
            AND lexicon.gloss != ''
        )
        """
    )
    print(f"   tokens: {cur.rowcount}")

    cur.execute(
        "INSERT OR REPLACE INTO meta(key,value) VALUES ('lexicon_lang','pt')"
    )
    cur.execute(
        """
        INSERT OR REPLACE INTO meta(key,value) VALUES (
          'attribution',
          'Léxico e texto etiquetado: STEPBible / Tyndale House Cambridge (CC BY 4.0). '
          'Referências cruzadas: openbible.info (CC BY). '
          'Definições traduzidas automaticamente para português.'
        )
        """
    )
    con.commit()
    con.execute("VACUUM")
    con.close()

    print("7) Compactando…")
    with DB.open("rb") as src, gzip.open(GZ, "wb", compresslevel=9) as dst:
        dst.write(src.read())
    print(f"   {GZ.name} ({GZ.stat().st_size:,} bytes)")

    # Amostra
    con = sqlite3.connect(DB)
    for sid in ("H5175", "H0430", "G0025", "G0026"):
        r = con.execute(
            "SELECT gloss, substr(definition,1,80) FROM lexicon WHERE id=?", (sid,)
        ).fetchone()
        print(f"   {sid}: {r}")
    con.close()
    print("Pronto.")


if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print("\nInterrompido — cache salvo.")
        sys.exit(1)
