#!/usr/bin/env python3
"""Translate tool/partials/epistolas_{en,es}_*.json → *_out.json and merge into cache."""
from __future__ import annotations

import argparse
import json
import sys
import time
from concurrent.futures import ThreadPoolExecutor, as_completed
from pathlib import Path
from threading import Lock

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "tool"))
from build_question_overlays import (  # noqa: E402
    load_cache,
    postprocess,
    save_cache,
    translate_raw,
)

PARTIALS = ROOT / "tool/partials"
_lock = Lock()


def translate_batch(path: Path, lang: str, workers: int, cache: dict) -> Path:
    srcs = json.loads(path.read_text())
    if not isinstance(srcs, list):
        raise SystemExit(f"expected list in {path}")
    bucket = cache.setdefault(lang, {})
    # skip already cached
    todo = [s for s in srcs if isinstance(s, str) and s.strip() and s not in bucket]
    out_map: dict[str, str] = {s: bucket[s] for s in srcs if s in bucket}
    print(f"{path.name}: {len(todo)} to translate / {len(srcs)} ({lang})", flush=True)
    if not todo:
        out_path = path.with_name(path.stem + "_out.json")
        out_path.write_text(json.dumps(out_map, ensure_ascii=False) + "\n")
        return out_path

    done = 0
    fails = 0

    def work(s: str) -> tuple[str, str]:
        return s, translate_raw(s, lang)

    with ThreadPoolExecutor(max_workers=max(1, workers)) as ex:
        futs = [ex.submit(work, s) for s in todo]
        for fut in as_completed(futs):
            try:
                src, dst = fut.result()
            except Exception as e:  # noqa: BLE001
                fails += 1
                print(f"  FAIL {path.name}: {e}", file=sys.stderr, flush=True)
                continue
            with _lock:
                bucket[src] = dst
                out_map[src] = dst
                done += 1
                if done % 50 == 0 or done == len(todo):
                    save_cache(cache)
                    print(
                        f"  {path.name} {done}/{len(todo)} fails={fails} cached={len(bucket)}",
                        flush=True,
                    )
    out_path = path.with_name(path.stem + "_out.json")
    out_path.write_text(json.dumps(out_map, ensure_ascii=False) + "\n")
    print(f"wrote {out_path.name} ({len(out_map)} entries, fails={fails})", flush=True)
    return out_path


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--lang", choices=["en", "es", "both"], default="both")
    ap.add_argument("--workers", type=int, default=4)
    ap.add_argument("--start", type=int, default=0)
    ap.add_argument("--end", type=int, default=10_000)
    args = ap.parse_args()

    langs = ["en", "es"] if args.lang == "both" else [args.lang]
    cache = load_cache()
    t0 = time.time()
    for lang in langs:
        paths = sorted(PARTIALS.glob(f"epistolas_{lang}_[0-9][0-9][0-9].json"))
        # exclude *_out.json (pattern already does)
        paths = [p for p in paths if not p.name.endswith("_out.json")]
        for p in paths:
            idx = int(p.stem.rsplit("_", 1)[-1])
            if idx < args.start or idx >= args.end:
                continue
            translate_batch(p, lang, args.workers, cache)
            save_cache(cache)
    save_cache(cache)
    print(f"Done in {time.time()-t0:.1f}s cache en={len(cache['en'])} es={len(cache['es'])}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
