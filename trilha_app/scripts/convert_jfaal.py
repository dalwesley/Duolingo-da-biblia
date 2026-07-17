#!/usr/bin/env python3
"""Converte JFAAL (atualizada) para o formato do BibleService.

Uso:
  python3 scripts/convert_jfaal.py [caminho/1911-JFAAtualizadaLivre.json]

Se nenhum caminho for passado, baixa a versão atualizada do GitHub.
Saída: assets/data/bible_jfaal.json

Fonte: https://github.com/BibliaJFAAL/JFAAL
Crédito: JFAAL © Marcos Cristiano Alves Ferreira · CC BY 3.0 BR / MIT
"""

from __future__ import annotations

import json
import sys
import urllib.request
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
TB_PATH = ROOT / "assets" / "data" / "bible_tb.json"
OUT_PATH = ROOT / "assets" / "data" / "bible_jfaal.json"
DEFAULT_URL = (
    "https://raw.githubusercontent.com/BibliaJFAAL/JFAAL/main/"
    "atualizada/1911-JFAAtualizadaLivre.json"
)


def load_jfaal(path: Path | None) -> dict:
    if path is not None:
        with path.open(encoding="utf-8") as f:
            return json.load(f)
    print(f"Baixando {DEFAULT_URL} …")
    with urllib.request.urlopen(DEFAULT_URL, timeout=120) as resp:
        return json.load(resp)


def main() -> None:
    src_path = Path(sys.argv[1]) if len(sys.argv) > 1 else None
    jfaal = load_jfaal(src_path)
    with TB_PATH.open(encoding="utf-8") as f:
        tb = json.load(f)

    books = jfaal["books"] if isinstance(jfaal, dict) else jfaal
    if len(books) != len(tb):
        raise SystemExit(
            f"Esperado {len(tb)} livros, recebeu {len(books)}"
        )

    converted = []
    for src_book, tb_book in zip(books, tb):
        chapters = [
            [v["text"].strip() for v in ch["verses"]]
            for ch in src_book["chapters"]
        ]
        converted.append(
            {
                "abbrev": tb_book["abbrev"],
                "name": tb_book["name"],
                "chapters": chapters,
            }
        )

    OUT_PATH.write_text(
        json.dumps(converted, ensure_ascii=False, separators=(",", ":")),
        encoding="utf-8",
    )
    print(f"Escrito {OUT_PATH} ({OUT_PATH.stat().st_size:,} bytes)")


if __name__ == "__main__":
    main()
