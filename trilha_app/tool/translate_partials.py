#!/usr/bin/env python3
"""Translate tool/partials/{pack}_{lang}_{nnn}.json lists → *_out.json dicts.

Uses Google gtx (parallel) with Argos fallback. Merges into overlay cache
and optionally assembles questions_{lang}.json / studies_{lang}.json.
"""
from __future__ import annotations

import argparse
import json
import re
import sys
import time
from concurrent.futures import ThreadPoolExecutor, as_completed
from pathlib import Path
from threading import Lock

ROOT = Path(__file__).resolve().parents[1]
PARTIALS = ROOT / "tool/partials"
sys.path.insert(0, str(ROOT / "tool"))
from build_question_overlays import (  # noqa: E402
    assemble_questions,
    assemble_studies,
    gtx_translate,
    load_cache,
    postprocess,
    save_cache,
)

ES_USTED = [
    (re.compile(r"\bUsted\b"), "Tú"),
    (re.compile(r"\busted\b"), "tú"),
]


def polish(text: str, lang: str) -> str:
    out = postprocess(text, lang)
    if lang == "es":
        for pat, rep in ES_USTED:
            out = pat.sub(rep, out)
    return out.strip()


_backend = "auto"  # set via --backend


def translate_one(text: str, lang: str) -> str:
    last = None
    prefer = _backend
    order = []
    if prefer == "argos":
        order = ["argos", "gtx"]
    elif prefer == "gtx":
        order = ["gtx", "argos"]
    else:
        order = ["argos", "gtx"]

    for backend in order:
        if backend == "argos":
            try:
                import argostranslate.translate

                raw = argostranslate.translate.translate(text, "pt", lang)
                if raw and str(raw).strip():
                    return polish(str(raw), lang)
            except Exception as e:  # noqa: BLE001
                last = f"argos={e}"
                continue
        else:
            for attempt in range(4):
                try:
                    return polish(gtx_translate(text, lang), lang)
                except Exception as e:  # noqa: BLE001
                    last = f"gtx={e}"
                    time.sleep(min(12.0, 0.8 * (1.6**attempt)))
    raise RuntimeError(f"Failed {text[:50]!r}: {last}")


def process_batch(path: Path, lang: str, workers: int, skip_existing: bool) -> Path:
    out_path = path.with_name(path.stem + "_out.json")
    srcs = json.loads(path.read_text())
    if not isinstance(srcs, list):
        raise SystemExit(f"expected list in {path.name}")
    result: dict = {}
    if skip_existing and out_path.exists():
        try:
            data = json.loads(out_path.read_text())
            if isinstance(data, dict):
                result = data
        except Exception:  # noqa: BLE001
            result = {}
    todo = [s for s in srcs if s and s not in result]
    print(
        f"  {path.name}: {len(todo)} to translate / {len(srcs)} (have {len(result)})",
        flush=True,
    )
    if not todo:
        return out_path

    lock = Lock()
    done = 0
    t0 = time.time()

    def work(s: str) -> tuple[str, str]:
        return s, translate_one(s, lang)

    with ThreadPoolExecutor(max_workers=max(1, workers)) as ex:
        futs = [ex.submit(work, s) for s in todo]
        for fut in as_completed(futs):
            try:
                src, dst = fut.result()
            except Exception as e:  # noqa: BLE001
                print(f"    FAIL: {e}", file=sys.stderr, flush=True)
                continue
            with lock:
                result[src] = dst
                done += 1
                if done % 25 == 0 or done == len(todo):
                    out_path.write_text(json.dumps(result, ensure_ascii=False) + "\n")
                    elapsed = time.time() - t0
                    rate = done / elapsed if elapsed else 0
                    print(f"    {done}/{len(todo)} rate={rate:.1f}/s", flush=True)
    out_path.write_text(json.dumps(result, ensure_ascii=False) + "\n")
    return out_path


def merge_outs_to_cache(pattern: str, lang: str) -> int:
    cache = load_cache()
    bucket = cache.setdefault(lang, {})
    added = 0
    for path in sorted(PARTIALS.glob(pattern)):
        data = json.loads(path.read_text())
        if not isinstance(data, dict):
            continue
        before = len(bucket)
        for k, v in data.items():
            if k and v and str(v).strip():
                bucket[k] = str(v).strip()
        added += len(bucket) - before
        print(f"  merged {path.name} +{len(bucket) - before}", flush=True)
    save_cache(cache)
    print(f"cache {lang}={len(bucket)} (+{added})", flush=True)
    return added


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--pack", required=True)
    ap.add_argument("--lang", required=True, choices=["en", "es"])
    ap.add_argument("--start", type=int, default=0)
    ap.add_argument("--end", type=int, default=10**9)
    ap.add_argument("--workers", type=int, default=8)
    ap.add_argument(
        "--backend",
        choices=["auto", "argos", "gtx"],
        default="argos",
        help="argos=offline stable; gtx=faster but rate-limited",
    )
    ap.add_argument("--skip-existing", action="store_true", default=True)
    ap.add_argument("--no-skip-existing", action="store_false", dest="skip_existing")
    ap.add_argument("--assemble", action="store_true")
    ap.add_argument("--studies", action="store_true")
    ap.add_argument("--merge-only", action="store_true")
    args = ap.parse_args()

    global _backend
    _backend = args.backend
    if args.backend == "argos" and args.workers > 1:
        # Stanza/Argos does not parallelize well across threads.
        print(f"note: clamping workers {args.workers}→1 for argos", flush=True)
        args.workers = 1

    if not args.merge_only:
        print("warmup:", translate_one("Deus é o centro, não eu", args.lang), flush=True)
        paths = sorted(PARTIALS.glob(f"{args.pack}_{args.lang}_[0-9][0-9][0-9].json"))
        selected = []
        for p in paths:
            try:
                idx = int(p.stem.rsplit("_", 1)[-1])
            except ValueError:
                continue
            if args.start <= idx <= args.end:
                selected.append(p)
        print(
            f"batches: {len(selected)} ({args.pack}/{args.lang} "
            f"[{args.start}..{args.end}] workers={args.workers})",
            flush=True,
        )
        for p in selected:
            process_batch(p, args.lang, args.workers, args.skip_existing)

    merge_outs_to_cache(f"{args.pack}_{args.lang}_*_out.json", args.lang)

    if args.assemble:
        cache = load_cache()
        if args.pack in (
            "buracos",
            "ot",
            "genesis",
            "exodo",
            "sermao",
            "nt",
            "epistolas",
        ):
            assemble_questions([args.pack], args.lang, cache)
        if args.studies or args.pack == "studies":
            assemble_studies(args.lang, cache)
    print("Done.", flush=True)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
