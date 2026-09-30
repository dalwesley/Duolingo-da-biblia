#!/usr/bin/env python3
"""Assemble epistolas overlays from cache and merge into questions_{en,es}.json.

Does NOT delete existing keys; only upserts epistolas question ids.
"""
from __future__ import annotations

import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "tool"))
from build_question_overlays import build_entry, load_cache  # noqa: E402

DATA = ROOT / "assets/data/epistolas_questions.json"
OUT_DIR = ROOT / "assets/l10n/content"


def main() -> int:
    qs = json.loads(DATA.read_text())["questions"]
    cache = load_cache()
    ids = [q["id"] for q in qs if q.get("id")]
    print(f"epistolas questions: {len(ids)}")

    for lang in ("en", "es"):
        overlay_path = OUT_DIR / f"questions_{lang}.json"
        existing = json.loads(overlay_path.read_text())
        before = len(existing)
        before_epi = sum(1 for i in ids if i in existing)

        built = 0
        empty = 0
        for q in qs:
            qid = q.get("id")
            if not qid:
                continue
            entry = build_entry(q, lang, cache)
            if not entry:
                empty += 1
                continue
            # merge fields into existing entry if present
            cur = existing.get(qid) or {}
            cur.update(entry)
            existing[qid] = cur
            built += 1

        overlay_path.write_text(json.dumps(existing, ensure_ascii=False) + "\n")
        after_epi = sum(1 for i in ids if i in existing)
        print(
            f"{lang}: wrote {overlay_path.name} total={len(existing)} "
            f"(was {before}) epistolas_ids={after_epi} "
            f"(was {before_epi}) built={built} empty={empty}"
        )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
