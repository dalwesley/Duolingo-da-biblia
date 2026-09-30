#!/usr/bin/env python3
"""Merge miss_*_out.json translation dicts into the overlay cache, then assemble."""
from __future__ import annotations

import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PARTIALS = ROOT / "tool/question_overlay_partials"
CACHE_PATH = ROOT / "tool/.question_overlay_cache.json"


def main() -> int:
    cache = {"en": {}, "es": {}}
    if CACHE_PATH.exists():
        cache = json.loads(CACHE_PATH.read_text())
    cache.setdefault("en", {})
    cache.setdefault("es", {})

    added = {"en": 0, "es": 0}
    for path in sorted(PARTIALS.glob("miss_*_out.json")):
        name = path.name
        lang = "es" if "_es_" in name else "en"
        data = json.loads(path.read_text())
        if not isinstance(data, dict):
            print(f"skip non-object {path.name}", file=sys.stderr)
            continue
        bucket = cache[lang]
        before = len(bucket)
        for k, v in data.items():
            if k and v and str(v).strip():
                bucket[k] = str(v).strip()
        added[lang] += len(bucket) - before
        print(f"merged {path.name} → {lang} +{len(bucket)-before}")

    CACHE_PATH.write_text(json.dumps(cache, ensure_ascii=False) + "\n")
    print(f"cache en={len(cache['en'])} es={len(cache['es'])} added={added}")

    # assemble
    import subprocess

    r = subprocess.run(
        [
            sys.executable,
            str(ROOT / "tool/build_question_overlays.py"),
            "--assemble-only",
            "--langs",
            "en",
            "es",
        ],
        cwd=str(ROOT),
    )
    return r.returncode


if __name__ == "__main__":
    raise SystemExit(main())
