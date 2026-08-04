#!/usr/bin/env python3
"""Fill empty trails: 4 gospels + vida cristã + teologia."""
from __future__ import annotations

import json
from pathlib import Path

from _buracos_evangelhos_data import EVANGELHOS_BOOKS
from _buracos_teologia_data import TEOLOGIA
from _buracos_vida_crista_data import VIDA_CRISTA

ROOT = Path(__file__).resolve().parents[2]
ASSETS = ROOT / "trilha_app" / "assets" / "data"
DART = ROOT / "trilha_app" / "lib" / "utils" / "difficulty_trails.dart"
SEED = ROOT / "admin" / "scripts" / "seed_content.mjs"
SHORT = {"semente": "sem", "caminhada": "cam", "profundezas": "pro"}


def make_question(trail: str, section: str, diff: str, n: int, seed: dict, stem: str) -> dict:
    answer = seed["answer"]
    wrongs = list(seed["wrong"])
    slot = (n + hash(section + diff) % 3) % 4
    texts = wrongs[:]
    texts.insert(slot, answer)
    ids = ["a", "b", "c", "d"]
    correct_id = ids[slot]
    opt_list = [{"id": i, "text": t} for i, t in zip(ids, texts)]
    wrong_fb = {
        i: "Não é o que o texto ensina — revise a passagem."
        for i in ids
        if i != correct_id
    }
    return {
        "id": f"{trail}-{SHORT[diff]}-{section}-{n:02d}",
        "trail": trail,
        "difficulty": diff,
        "section": section,
        "question": stem,
        "options": opt_list,
        "correctOptionId": correct_id,
        "feedbackCorrect": "Correto!",
        "feedbackWrong": wrong_fb,
        "verseRef": seed["verse"],
        "reveal": None,
    }


def expand_bank(trail: str, missions: list) -> list:
    out = []
    for m in missions:
        section = m["slug"]
        for i, seed in enumerate(m["seeds"], 1):
            out.append(make_question(trail, section, "semente", i, seed, seed["q_s"]))
            out.append(make_question(trail, section, "caminhada", i, seed, seed["q_c"]))
            out.append(make_question(trail, section, "profundezas", i, seed, seed["q_p"]))
    return out


def mission_obj(m: dict) -> dict:
    return {
        "slug": m["slug"],
        "title": m["title"],
        "subtitle": m.get("subtitle") or "",
        "intro": m["intro"],
        "type": "boss" if m.get("boss") else "lesson",
        "xpReward": 110 if m.get("boss") else 60,
        "questions": [],
    }


def study_obj(m: dict) -> dict | None:
    if m.get("boss") or not m.get("study"):
        return None
    s = m["study"]
    return {
        "slug": m["slug"],
        "passageRef": s["passageRef"],
        "passageText": s["passageText"],
        "context": s["context"],
        "keyword": s["keyword"],
        "keywordGloss": s["keywordGloss"],
        "focusQuestion": s["focusQuestion"],
        "reflectionPrompts": s["reflectionPrompts"],
    }


def main() -> None:
    all_trails = {**EVANGELHOS_BOOKS, **VIDA_CRISTA, **TEOLOGIA}
    trails_path = ASSETS / "trails.json"
    trails = json.loads(trails_path.read_text(encoding="utf-8"))
    by_slug = {t["slug"]: t for t in trails}

    bank_all = []
    studies_new = {}
    verse_map = {}

    for slug, spec in all_trails.items():
        t = by_slug.get(slug)
        if not t:
            raise SystemExit(f"trail missing: {slug}")
        mod = spec["module"]
        missions = [mission_obj(m) for m in spec["missions"]]
        t["modules"] = [
            {
                "title": mod["title"],
                "icon": mod.get("icon") or "📖",
                "section": mod.get("section") or slug,
                "missions": missions,
            }
        ]
        t["comingSoon"] = False
        t["isActive"] = True
        bank_all.extend(expand_bank(slug, spec["missions"]))
        for m in spec["missions"]:
            st = study_obj(m)
            if st:
                studies_new[m["slug"]] = st
                verse_map[st["passageRef"]] = st["passageText"]

    trails_path.write_text(json.dumps(trails, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")

    bank_path = ASSETS / "buracos_questions.json"
    bank_path.write_text(
        json.dumps({"questions": bank_all}, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )

    studies_path = ASSETS / "mission_studies.json"
    studies_data = json.loads(studies_path.read_text(encoding="utf-8"))
    studies_data.setdefault("studies", {}).update(studies_new)
    studies_data.setdefault("verses", {}).update(verse_map)
    studies_path.write_text(json.dumps(studies_data, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")

    dart = DART.read_text(encoding="utf-8")
    new_slugs = sorted(all_trails.keys())
    missing = [s for s in new_slugs if f"'{s}'" not in dart]
    if missing:
        block = ",\n  ".join(f"'{s}'" for s in missing)
        dart = dart.replace(
            "  'tito',\n};",
            "  'tito',\n  // Buracos preenchidos\n  " + block + ",\n};",
        )
        if "hermeneutica" not in dart:
            # fallback if epistolas block format differs
            dart = dart.replace(
                "};\n\nbool trailUsesDifficultyBank",
                "  // Buracos preenchidos\n  " + block + ",\n};\n\nbool trailUsesDifficultyBank",
            )
        DART.write_text(dart, encoding="utf-8")

    seed = SEED.read_text(encoding="utf-8")
    if "buracos_questions.json" not in seed:
        seed = seed.replace(
            "['epistolas_questions.json', null],\n  ];",
            "['epistolas_questions.json', null],\n"
            "    ['buracos_questions.json', null],\n  ];",
        )
        if "buracos_questions.json" not in seed:
            seed = seed.replace(
                "['sermao_questions.json', 'sermao-do-monte'],\n  ];",
                "['sermao_questions.json', 'sermao-do-monte'],\n"
                "    ['epistolas_questions.json', null],\n"
                "    ['buracos_questions.json', null],\n  ];",
            )
        SEED.write_text(seed, encoding="utf-8")

    print(f"trails: {len(all_trails)}")
    print(f"missions: {sum(len(s['missions']) for s in all_trails.values())}")
    print(f"bank: {len(bank_all)}")
    print(f"studies: {len(studies_new)}")


if __name__ == "__main__":
    main()
