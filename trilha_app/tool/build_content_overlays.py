#!/usr/bin/env python3
"""Build trails_{en,es}.json and bible_intros_{en,es}.json via Google gtx."""
from __future__ import annotations

import json
import re
import sys
import time
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
TRAILS_SRC = ROOT / "assets/data/trails.json"
INTROS_DART = ROOT / "lib/data/bible_book_intros.dart"
OUT_DIR = ROOT / "assets/l10n/content"
CACHE_PATH = ROOT / "tool/.content_overlay_cache.json"

MISSION_FIELDS = (
    "title",
    "intro",
    "centralInsight",
    "objective",
    "hookNote",
    "echoQuestion",
)

POST_EN = {
    "Tradição:": "Tradition:",
    "Desconhecido": "Unknown",
    "séc.": "c.",
    "a.C.": "B.C.",
    "d.C.": "A.D.",
}
POST_ES = {
    "Tradição:": "Tradición:",
    "Desconhecido": "Desconocido",
    "séc.": "s.",
}

# Prefer biblical book names over awkward MT abbreviations.
BOOK_FIX_EN = {
    "Exod.": "Exodus",
    "Lev.": "Leviticus",
    "Num.": "Numbers",
    "Deut.": "Deuteronomy",
    "Ps.": "Psalms",
    "Prov.": "Proverbs",
    "Eccles.": "Ecclesiastes",
    "Songs": "Song of Songs",
    "Canticles": "Song of Songs",
    "Jonas": "Jonah",
    "Isa.": "Isaiah",
    "Jer.": "Jeremiah",
    "Lam.": "Lamentations",
    "Ezek.": "Ezekiel",
    "Dan.": "Daniel",
    "Hos.": "Hosea",
    "Obad.": "Obadiah",
    "Mic.": "Micah",
    "Nah.": "Nahum",
    "Hab.": "Habakkuk",
    "Zeph.": "Zephaniah",
    "Hag.": "Haggai",
    "Zech.": "Zechariah",
    "Mal.": "Malachi",
    "Matt.": "Matthew",
    "Rom.": "Romans",
    "Cor.": "Corinthians",
    "Gal.": "Galatians",
    "Eph.": "Ephesians",
    "Phil.": "Philippians",
    "Col.": "Colossians",
    "Thess.": "Thessalonians",
    "Tim.": "Timothy",
    "Tit.": "Titus",
    "Philem.": "Philemon",
    "Heb.": "Hebrews",
    "Jas.": "James",
    "Pet.": "Peter",
    "Rev.": "Revelation",
}


def load_cache() -> dict:
    if CACHE_PATH.exists():
        return json.loads(CACHE_PATH.read_text())
    return {"en": {}, "es": {}}


def save_cache(cache: dict) -> None:
    CACHE_PATH.parent.mkdir(parents=True, exist_ok=True)
    CACHE_PATH.write_text(json.dumps(cache, ensure_ascii=False) + "\n")


def postprocess(text: str, lang: str) -> str:
    table = POST_EN if lang == "en" else POST_ES
    out = text
    for k, v in table.items():
        out = out.replace(k, v)
    if lang == "en":
        for k, v in BOOK_FIX_EN.items():
            out = re.sub(rf"\b{re.escape(k)}\b", v, out)
    if lang == "es":
        out = re.sub(r"\bUsted\b", "Tú", out)
        out = re.sub(r"\busted\b", "tú", out)
        # Soft tú: imperative/instructional "Su" → "Tu" only at sentence starts
        # is too aggressive; leave most as-is (Spanish MT already often uses tú).
    return out.strip()


def gtx_translate(text: str, target: str) -> str:
    """Google translate_a/single via curl (urllib hits 429 more often)."""
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


def translate_one(text: str, lang: str, cache: dict) -> str:
    if not text or not text.strip():
        return text
    bucket = cache.setdefault(lang, {})
    if text in bucket:
        return bucket[text]

    chunks: list[str] = []
    remaining = text
    while remaining:
        if len(remaining) <= 1500:  # keep curl URL shorter
            chunks.append(remaining)
            break
        cut = remaining.rfind(". ", 0, 1400)
        if cut < 200:
            cut = remaining.rfind(" ", 0, 1400) or 1400
        chunks.append(remaining[: cut + 1].rstrip())
        remaining = remaining[cut + 1 :].lstrip()

    parts = []
    for chunk in chunks:
        last_err = None
        for attempt in range(20):
            try:
                parts.append(gtx_translate(chunk, lang))
                time.sleep(0.4)
                break
            except Exception as e:  # noqa: BLE001
                last_err = e
                wait = min(120.0, 3.0 * (1.6**attempt))
                print(
                    f"  retry {attempt+1} ({lang}) wait={wait:.1f}s: {e}",
                    file=sys.stderr,
                    flush=True,
                )
                time.sleep(wait)
        else:
            raise RuntimeError(f"Failed: {chunk[:60]!r} ({last_err})")
    result = postprocess(" ".join(parts), lang)
    bucket[text] = result
    if len(bucket) % 15 == 0:
        save_cache(cache)
        print(f"  cached {lang}: {len(bucket)}", flush=True)
    return result


def extract_trails_overlay(trails: list) -> dict:
    out = {"trails": {}, "modules": {}, "missions": {}}
    for t in trails:
        slug = t["slug"]
        trail_entry = {}
        if (t.get("title") or "").strip():
            trail_entry["title"] = t["title"].strip()
        if (t.get("description") or "").strip():
            trail_entry["description"] = t["description"].strip()
        if trail_entry:
            out["trails"][slug] = trail_entry
        for i, mod in enumerate(t.get("modules") or []):
            title = (mod.get("title") or "").strip()
            if title:
                out["modules"][f"{slug}:{i}"] = {"title": title}
            for ms in mod.get("missions") or []:
                mslug = ms.get("slug")
                if not mslug:
                    continue
                entry = {}
                for f in MISSION_FIELDS:
                    v = (ms.get(f) or "").strip()
                    if v:
                        entry[f] = v
                if entry:
                    out["missions"][mslug] = entry
    return out


def parse_dart_intros(path: Path) -> dict:
    text = path.read_text()
    pattern = re.compile(
        r"'([a-z0-9]+)':\s*BibleBookIntro\(\s*"
        r"title:\s*'((?:\\'|[^'])*)',\s*"
        r"summary:\s*'((?:\\'|[^'])*)',\s*"
        r"author:\s*'((?:\\'|[^'])*)',\s*"
        r"when:\s*'((?:\\'|[^'])*)',\s*"
        r"audience:\s*'((?:\\'|[^'])*)',\s*"
        r"\)",
        re.S,
    )

    def unesc(s: str) -> str:
        return s.replace("\\'", "'").replace("\\n", "\n")

    out = {}
    for m in pattern.finditer(text):
        key, title, summary, author, when, audience = m.groups()
        out[key] = {
            "title": unesc(title),
            "summary": unesc(summary),
            "author": unesc(author),
            "when": unesc(when),
            "audience": unesc(audience),
        }
    return out


def translate_tree(node, lang: str, cache: dict):
    if isinstance(node, dict):
        return {k: translate_tree(v, lang, cache) for k, v in node.items()}
    if isinstance(node, str):
        return translate_one(node, lang, cache)
    return node


def main() -> int:
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    cache = load_cache()

    trails = json.loads(TRAILS_SRC.read_text())
    pt_overlay = extract_trails_overlay(trails)
    print(
        f"PT overlay: trails={len(pt_overlay['trails'])} "
        f"modules={len(pt_overlay['modules'])} "
        f"missions={len(pt_overlay['missions'])}",
        flush=True,
    )

    intros = parse_dart_intros(INTROS_DART)
    print(f"Bible intros: {len(intros)}", flush=True)

    # Warm-up
    print("warmup:", gtx_translate("Deus é o centro, não eu", "en"), flush=True)

    for lang in ("en", "es"):
        print(f"\n=== trails → {lang} ===", flush=True)
        translated = translate_tree(pt_overlay, lang, cache)
        path = OUT_DIR / f"trails_{lang}.json"
        path.write_text(json.dumps(translated, ensure_ascii=False, indent=2) + "\n")
        print(f"Wrote {path} missions={len(translated['missions'])}", flush=True)

        print(f"=== bible intros → {lang} ===", flush=True)
        intros_t = translate_tree(intros, lang, cache)
        ipath = OUT_DIR / f"bible_intros_{lang}.json"
        ipath.write_text(json.dumps(intros_t, ensure_ascii=False, indent=2) + "\n")
        print(f"Wrote {ipath}", flush=True)
        save_cache(cache)

    (OUT_DIR / "bible_intros_pt.json").write_text(
        json.dumps(intros, ensure_ascii=False, indent=2) + "\n"
    )
    print("Done.", flush=True)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
