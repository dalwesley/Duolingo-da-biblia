#!/usr/bin/env python3
"""Merge lib/l10n/parts/*.json into lib/l10n/app_{pt,en,es}.arb and run gen-l10n.

Each part file maps a key to its three translations:

    "homeTitle": {"pt": "Hoje", "en": "Today", "es": "Hoy"}
    "homeDays": {"pt": "{count, plural, =1{1 dia} other{{count} dias}}", ...,
                 "placeholders": {"count": "int"}}

The ARB files are generated: edit the parts, never the ARB.
Usage: python3 tool/l10n_merge.py [--no-gen]
"""
import fcntl
import json
import pathlib
import re
import subprocess
import sys

ROOT = pathlib.Path(__file__).resolve().parent.parent
PARTS = ROOT / "lib" / "l10n" / "parts"
OUT = ROOT / "lib" / "l10n"
LOCALES = ["pt", "en", "es"]
PLACEHOLDER = re.compile(r"\{(\w+)(?:[,}])")


def main() -> int:
    lock = open(ROOT / "build" / ".l10n.lock", "w") if (ROOT / "build").exists() else None
    if lock is None:
        (ROOT / "build").mkdir(exist_ok=True)
        lock = open(ROOT / "build" / ".l10n.lock", "w")
    fcntl.flock(lock, fcntl.LOCK_EX)

    merged: dict[str, dict] = {}
    owner: dict[str, str] = {}
    errors: list[str] = []
    for part in sorted(PARTS.glob("*.json")):
        try:
            data = json.loads(part.read_text(encoding="utf-8"))
        except json.JSONDecodeError as e:
            errors.append(f"{part.name}: invalid JSON ({e})")
            continue
        for key, entry in data.items():
            if key in merged:
                errors.append(f"{key}: in {owner[key]} and {part.name}")
                continue
            if not re.fullmatch(r"[a-z][A-Za-z0-9]*", key):
                errors.append(f"{part.name}: bad key '{key}' (lowerCamelCase)")
            declared = set((entry.get("placeholders") or {}).keys())
            for loc in LOCALES:
                text = entry.get(loc)
                if not isinstance(text, str) or not text:
                    errors.append(f"{part.name}: {key} missing '{loc}'")
                    continue
                used = set(PLACEHOLDER.findall(text)) - {"plural", "select", "other"}
                # ICU inner branch names ("=1", "other") are not placeholders.
                used = {u for u in used if u in declared or not u.isdigit()}
                if used - declared:
                    errors.append(f"{part.name}: {key} [{loc}] undeclared {sorted(used - declared)}")
            merged[key] = entry
            owner[key] = part.name

    if errors:
        print("l10n merge failed:\n  " + "\n  ".join(errors), file=sys.stderr)
        return 1

    for loc in LOCALES:
        arb = {"@@locale": loc, "@@x-generated": "tool/l10n_merge.py — edit lib/l10n/parts"}
        for key in sorted(merged):
            entry = merged[key]
            arb[key] = entry[loc]
            if loc == "pt":
                meta = {}
                if entry.get("description"):
                    meta["description"] = entry["description"]
                if entry.get("placeholders"):
                    meta["placeholders"] = {n: {"type": t} for n, t in entry["placeholders"].items()}
                if meta:
                    arb["@" + key] = meta
        (OUT / f"app_{loc}.arb").write_text(
            json.dumps(arb, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
        )
    print(f"l10n: {len(merged)} keys from {len(set(owner.values()))} parts")

    if "--no-gen" not in sys.argv:
        r = subprocess.run(["flutter", "gen-l10n"], cwd=ROOT, capture_output=True, text=True)
        if r.returncode != 0:
            print(r.stdout + r.stderr, file=sys.stderr)
            return r.returncode
    return 0


if __name__ == "__main__":
    sys.exit(main())
