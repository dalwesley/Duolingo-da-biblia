#!/usr/bin/env python3
"""Build questions_{en,es}.json and studies_{en,es}.json overlays.

Phase 1: collect unique pedagogical strings
Phase 2: translate missing via Google gtx (curl) with cache + workers
Phase 3: assemble per-question overlays (no network)
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
from typing import Optional

ROOT = Path(__file__).resolve().parents[1]
DATA = ROOT / "assets/data"
OUT_DIR = ROOT / "assets/l10n/content"
CACHE_PATH = ROOT / "tool/.question_overlay_cache.json"

PACKS = ["genesis", "exodo", "sermao", "nt", "epistolas", "buracos", "ot"]

SEED_EN = {
    "Verdadeiro": "True",
    "Falso": "False",
    "Correto.": "Correct.",
    "Correto!": "Correct!",
    "Quase.": "Almost.",
}
SEED_ES = {
    "Verdadeiro": "Verdadero",
    "Falso": "Falso",
    "Correto.": "Correcto.",
    "Correto!": "¡Correcto!",
    "Quase.": "Casi.",
}

POST_EN = {
    "Gênesis": "Genesis",
    "Êxodo": "Exodus",
    "Levítico": "Leviticus",
    "Números": "Numbers",
    "Deuteronômio": "Deuteronomy",
    "Salmos": "Psalms",
    "Provérbios": "Proverbs",
    "Eclesiastes": "Ecclesiastes",
    "Isaías": "Isaiah",
    "Jeremias": "Jeremiah",
    "Ezequiel": "Ezekiel",
    "Mateus": "Matthew",
    "Marcos": "Mark",
    "Lucas": "Luke",
    "João": "John",
    "Atos": "Acts",
    "Romanos": "Romans",
    "Coríntios": "Corinthians",
    "Gálatas": "Galatians",
    "Efésios": "Ephesians",
    "Filipenses": "Philippians",
    "Colossenses": "Colossians",
    "Tessalonicenses": "Thessalonians",
    "Timóteo": "Timothy",
    "Tito": "Titus",
    "Filemom": "Philemon",
    "Hebreus": "Hebrews",
    "Tiago": "James",
    "Pedro": "Peter",
    "Judas": "Jude",
    "Apocalipse": "Revelation",
}
POST_ES = {
    "Gênesis": "Génesis",
    "Êxodo": "Éxodo",
    "Levítico": "Levítico",
    "Números": "Números",
    "Deuteronômio": "Deuteronomio",
    "Isaías": "Isaías",
    "Jeremias": "Jeremías",
    "Mateus": "Mateo",
    "João": "Juan",
    "Atos": "Hechos",
    "Coríntios": "Corintios",
    "Efésios": "Efesios",
    "Colossenses": "Colosenses",
    "Tessalonicenses": "Tesalonicenses",
    "Timóteo": "Timoteo",
    "Filemom": "Filemón",
    "Hebreus": "Hebreos",
    "Tiago": "Santiago",
    "Apocalipse": "Apocalipsis",
}

_cache_lock = Lock()


def load_cache() -> dict:
    if CACHE_PATH.exists():
        data = json.loads(CACHE_PATH.read_text())
    else:
        data = {"en": {}, "es": {}}
    for lang, seed in (("en", SEED_EN), ("es", SEED_ES)):
        bucket = data.setdefault(lang, {})
        for k, v in seed.items():
            bucket.setdefault(k, v)
    return data


def save_cache(cache: dict) -> None:
    CACHE_PATH.parent.mkdir(parents=True, exist_ok=True)
    # keep file smaller: write without indent
    CACHE_PATH.write_text(json.dumps(cache, ensure_ascii=False) + "\n")


def postprocess(text: str, lang: str) -> str:
    table = POST_EN if lang == "en" else POST_ES
    out = text
    for k, v in table.items():
        out = out.replace(k, v)
    if lang == "es":
        out = re.sub(r"\bUsted\b", "Tú", out)
        out = re.sub(r"\busted\b", "tú", out)
    return out.strip()


def gtx_translate(text: str, target: str) -> str:
    import subprocess

    cmd = [
        "curl",
        "-sS",
        "-G",
        "https://translate.googleapis.com/translate_a/single",
        "--data-urlencode",
        "client=gtx",
        "--data-urlencode",
        "sl=pt",
        "--data-urlencode",
        f"tl={target}",
        "--data-urlencode",
        "dt=t",
        "--data-urlencode",
        f"q={text}",
        "-A",
        "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36",
        "--max-time",
        "45",
    ]
    proc = subprocess.run(cmd, capture_output=True, text=True, check=False)
    if proc.returncode != 0:
        raise RuntimeError(proc.stderr.strip() or f"curl exit {proc.returncode}")
    raw = proc.stdout.strip()
    if not raw or raw.startswith("<!") or "Too Many Requests" in raw:
        raise RuntimeError(f"bad response: {raw[:120]!r}")
    data = json.loads(raw)
    parts = []
    if data and data[0]:
        for seg in data[0]:
            if seg and seg[0]:
                parts.append(seg[0])
    out = "".join(parts).strip()
    if not out:
        raise RuntimeError(f"empty translation for {text[:40]!r}")
    return out


def translate_raw(text: str, lang: str) -> str:
    """Translate via Argos (offline) with MyMemory/gtx fallback."""
    try:
        return postprocess(_argos(text, lang), lang)
    except Exception as e_argos:  # noqa: BLE001
        chunks: list[str] = []
        remaining = text
        limit = 450
        while remaining:
            if len(remaining) <= limit:
                chunks.append(remaining)
                break
            cut = remaining.rfind(". ", 0, limit)
            if cut < 80:
                cut = remaining.rfind(" ", 0, limit) or limit
            chunks.append(remaining[: cut + 1].rstrip())
            remaining = remaining[cut + 1 :].lstrip()

        parts = []
        for chunk in chunks:
            last_err = None
            for attempt in range(8):
                try:
                    parts.append(_mymemory(chunk, lang))
                    time.sleep(0.25)
                    break
                except Exception as e1:  # noqa: BLE001
                    try:
                        parts.append(gtx_translate(chunk, lang))
                        time.sleep(0.35)
                        break
                    except Exception as e2:  # noqa: BLE001
                        last_err = f"argos={e_argos}; mm={e1}; gtx={e2}"
                        wait = min(45.0, 2.0 * (1.4**attempt))
                        print(
                            f"  retry {attempt+1} ({lang}) wait={wait:.1f}s: {last_err}",
                            file=sys.stderr,
                            flush=True,
                        )
                        time.sleep(wait)
            else:
                raise RuntimeError(f"Failed: {chunk[:60]!r} ({last_err})")
        return postprocess(" ".join(parts), lang)


def _argos(text: str, lang: str) -> str:
    import argostranslate.translate

    out = argostranslate.translate.translate(text, "pt", lang)
    if not out or not str(out).strip():
        raise RuntimeError("empty argos")
    return str(out).strip()


def _mymemory(text: str, lang: str) -> str:
    from deep_translator import MyMemoryTranslator

    target = "en-US" if lang == "en" else "es-ES"
    out = MyMemoryTranslator(source="pt-BR", target=target).translate(text)
    if not out or not str(out).strip():
        raise RuntimeError("empty mymemory")
    return str(out).strip()


def option_is_verse_token(text: str, passage: str, qtype: str) -> bool:
    t = (text or "").strip()
    if not t:
        return True
    if qtype == "true_false":
        return False
    p = passage or ""
    if not p:
        return False
    return t in p


def collect_from_question(q: dict, into: set[str]) -> None:
    for f in ("question", "learningObjective", "feedbackCorrect"):
        v = (q.get(f) or "").strip()
        if v:
            into.add(v)
    fw = q.get("feedbackWrong") or {}
    if isinstance(fw, dict):
        for v in fw.values():
            s = str(v).strip() if v is not None else ""
            if s:
                into.add(s)
    passage = q.get("passageText") or ""
    qtype = q.get("type") or ""
    for o in q.get("options") or []:
        if not isinstance(o, dict):
            continue
        t = (o.get("text") or "").strip()
        if not t or option_is_verse_token(t, passage, qtype):
            continue
        into.add(t)


def collect_strings(packs: list[str], include_studies: bool) -> set[str]:
    strings: set[str] = set()
    for pack in packs:
        data = json.loads((DATA / f"{pack}_questions.json").read_text())
        for q in data["questions"]:
            collect_from_question(q, strings)
        print(f"  collected {pack}: running unique={len(strings)}", flush=True)
    if include_studies:
        studies = json.loads((DATA / "mission_studies.json").read_text())["studies"]
        for s in studies.values():
            for f in ("context", "focusQuestion", "keywordGloss"):
                v = (s.get(f) or "").strip()
                if v:
                    strings.add(v)
            for p in s.get("reflectionPrompts") or []:
                t = str(p).strip()
                if t:
                    strings.add(t)
        print(f"  +studies → unique={len(strings)}", flush=True)
    return strings


def fill_cache(strings: set[str], lang: str, cache: dict, workers: int) -> None:
    bucket = cache.setdefault(lang, {})
    missing = [s for s in strings if s not in bucket]
    print(f"=== translate → {lang}: {len(missing)} missing / {len(strings)} ===", flush=True)
    if not missing:
        return

    # Sort short→long so quick wins land first and batching stays compact.
    missing.sort(key=len)
    done = 0

    def work(s: str) -> tuple[str, str]:
        return s, translate_raw(s, lang)

    # Soft rate limit only needed for online backends; Argos is local/CPU-bound.
    with ThreadPoolExecutor(max_workers=max(1, workers)) as ex:
        futures = [ex.submit(work, s) for s in missing]
        for fut in as_completed(futures):
            try:
                src, dst = fut.result()
            except Exception as e:  # noqa: BLE001
                print(f"  FAIL: {e}", file=sys.stderr, flush=True)
                continue
            with _cache_lock:
                bucket[src] = dst
                done += 1
                if done % 100 == 0 or done == len(missing):
                    save_cache(cache)
                    print(f"  {lang}: {done}/{len(missing)} cached={len(bucket)}", flush=True)


def t(cache: dict, lang: str, text: str) -> Optional[str]:
    return cache.get(lang, {}).get(text)


def build_entry(q: dict, lang: str, cache: dict) -> dict:
    entry: dict = {}
    stem = (q.get("question") or "").strip()
    tr = t(cache, lang, stem) if stem else None
    if tr:
        entry["question"] = tr
    lo = (q.get("learningObjective") or "").strip()
    tr = t(cache, lang, lo) if lo else None
    if tr:
        entry["learningObjective"] = tr
    fc = (q.get("feedbackCorrect") or "").strip()
    tr = t(cache, lang, fc) if fc else None
    if fc and tr:
        entry["feedbackCorrect"] = tr
    fw = q.get("feedbackWrong") or {}
    if isinstance(fw, dict) and fw:
        fw_out = {}
        for k, v in fw.items():
            s = str(v).strip() if v is not None else ""
            if not s:
                continue
            tr = t(cache, lang, s)
            if tr:
                fw_out[str(k)] = tr
        if fw_out:
            entry["feedbackWrong"] = fw_out
    passage = q.get("passageText") or ""
    qtype = q.get("type") or ""
    opts_out = {}
    for o in q.get("options") or []:
        if not isinstance(o, dict):
            continue
        oid = str(o.get("id") or "")
        text = (o.get("text") or "").strip()
        if not oid or not text:
            continue
        if option_is_verse_token(text, passage, qtype):
            continue
        tr = t(cache, lang, text)
        if tr:
            opts_out[oid] = tr
    if opts_out:
        entry["options"] = opts_out
    return entry


def assemble_questions(packs: list[str], lang: str, cache: dict) -> dict:
    """Merge pack overlays into existing questions_{lang}.json (never wipe other packs)."""
    out = OUT_DIR / f"questions_{lang}.json"
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    merged: dict = {}
    if out.exists():
        try:
            existing = json.loads(out.read_text())
            if isinstance(existing, dict):
                merged = existing
        except Exception as e:  # noqa: BLE001
            print(f"  warn: could not load existing {out.name}: {e}", flush=True)
    counts: dict[str, int] = {}
    for pack in packs:
        data = json.loads((DATA / f"{pack}_questions.json").read_text())
        n = 0
        for q in data["questions"]:
            qid = q.get("id")
            if not qid:
                continue
            entry = build_entry(q, lang, cache)
            if entry:
                merged[qid] = entry
                n += 1
        counts[pack] = n
        print(f"  assemble {pack}/{lang}: {n}", flush=True)
    out.write_text(json.dumps(merged, ensure_ascii=False) + "\n")
    print(f"Wrote {out} total={len(merged)} packs={counts}", flush=True)
    return counts


def assemble_studies(lang: str, cache: dict) -> int:
    """Merge study overlays into existing studies_{lang}.json (never wipe)."""
    path = OUT_DIR / f"studies_{lang}.json"
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    out: dict = {}
    if path.exists():
        try:
            existing = json.loads(path.read_text())
            if isinstance(existing, dict):
                out = existing
        except Exception as e:  # noqa: BLE001
            print(f"  warn: could not load existing {path.name}: {e}", flush=True)
    studies = json.loads((DATA / "mission_studies.json").read_text())["studies"]
    for slug, s in studies.items():
        entry: dict = {}
        for f in ("context", "focusQuestion", "keywordGloss"):
            v = (s.get(f) or "").strip()
            if not v:
                continue
            tr = t(cache, lang, v)
            if tr:
                entry[f] = tr
        prompts = s.get("reflectionPrompts") or []
        if isinstance(prompts, list) and prompts:
            translated = []
            for p in prompts:
                src = str(p).strip()
                if not src:
                    continue
                tr = t(cache, lang, src)
                if tr:
                    translated.append(tr)
            if translated:
                entry["reflectionPrompts"] = translated
        if entry:
            out[slug] = entry
    path.write_text(json.dumps(out, ensure_ascii=False, indent=2) + "\n")
    print(f"Wrote {path} ({len(out)} studies)", flush=True)
    return len(out)


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--packs", nargs="*", default=PACKS)
    ap.add_argument("--langs", nargs="*", default=["en", "es"])
    ap.add_argument("--workers", type=int, default=8)
    ap.add_argument("--assemble-only", action="store_true")
    ap.add_argument("--skip-studies", action="store_true")
    args = ap.parse_args()

    OUT_DIR.mkdir(parents=True, exist_ok=True)
    cache = load_cache()

    if not args.assemble_only:
        try:
            print("warmup argos:", _argos("Deus é o centro, não eu", "en"), flush=True)
        except Exception as e:  # noqa: BLE001
            print(f"argos warmup failed ({e}); trying online fallbacks…", flush=True)
            try:
                print("warmup mm:", _mymemory("Deus é o centro, não eu", "en"), flush=True)
            except Exception as e2:  # noqa: BLE001
                print(f"warmup mm failed ({e2}); trying gtx…", flush=True)
                try:
                    print("warmup gtx:", gtx_translate("Deus é o centro, não eu", "en"), flush=True)
                except Exception as e3:  # noqa: BLE001
                    print(f"warmup gtx failed ({e3}); continuing with cache seeds", flush=True)
        strings = collect_strings(args.packs, include_studies=not args.skip_studies)
        print(f"Unique strings: {len(strings)}", flush=True)
        for lang in args.langs:
            fill_cache(strings, lang, cache, args.workers)
            save_cache(cache)

    for lang in args.langs:
        assemble_questions(args.packs, lang, cache)
        if not args.skip_studies:
            assemble_studies(lang, cache)

    save_cache(cache)
    print("Done.", flush=True)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
