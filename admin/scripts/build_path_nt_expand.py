#!/usr/bin/env python3
"""Densifica Atos (~10) e Apocalipse (~8); enriquece studies; ajusta unlock do caminho.

Também: Êxodo unlockAfter = genesis-12-50 (fio narrativo).

Usage: python3 admin/scripts/build_path_nt_expand.py
"""
from __future__ import annotations

import json
from pathlib import Path

from _path_nt_data import APOCALIPSE, ATOS

ROOT = Path(__file__).resolve().parents[2]
ASSETS = ROOT / "trilha_app" / "assets" / "data"
SHORT = {"semente": "sem", "caminhada": "cam", "profundezas": "pro"}


def make_question(trail: str, section: str, diff: str, n: int, seed: dict, stem: str) -> dict:
    answer = seed["answer"]
    wrongs = list(seed["wrong"])
    slot = (n + abs(hash(section + diff)) % 3) % 4
    texts = wrongs[:]
    texts.insert(slot, answer)
    ids = ["a", "b", "c", "d"]
    correct_id = ids[slot]
    return {
        "id": f"{trail}-{SHORT[diff]}-{section}-{n:02d}",
        "trail": trail,
        "difficulty": diff,
        "section": section,
        "question": stem,
        "options": [{"id": i, "text": t} for i, t in zip(ids, texts)],
        "correctOptionId": correct_id,
        "feedbackCorrect": "Correto!",
        "feedbackWrong": {
            i: "Não é o que o texto ensina — revise a passagem."
            for i in ids
            if i != correct_id
        },
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
        "xpReward": 120 if m.get("boss") else 60,
        "questions": [],
    }


def study_obj(m: dict) -> dict | None:
    if m.get("boss") or not m.get("study"):
        return None
    s = m["study"]
    out = {
        "slug": m["slug"],
        "passageRef": s["passageRef"],
        "passageText": s["passageText"],
        "context": s["context"],
        "keyword": s["keyword"],
        "keywordGloss": s["keywordGloss"],
        "focusQuestion": s["focusQuestion"],
        "reflectionPrompts": s["reflectionPrompts"],
    }
    if s.get("relatedVerses"):
        out["relatedVerses"] = s["relatedVerses"]
    return out


def all_missions(spec: dict) -> list:
    out = []
    for mod in spec["modules"]:
        out.extend(mod["missions"])
    return out


def apply_trail(trails: list, spec: dict) -> None:
    idx = next(i for i, t in enumerate(trails) if t["slug"] == spec["slug"])
    old = trails[idx]
    trails[idx] = {
        **{k: old[k] for k in old if k not in ("modules", "description", "unlockAfter", "title")},
        "slug": spec["slug"],
        "title": spec["title"],
        "description": spec["description"],
        "unlockAfter": spec["unlockAfter"],
        "comingSoon": False,
        "modules": [
            {
                "title": mod["title"],
                "icon": mod["icon"],
                "section": mod["section"],
                "missions": [mission_obj(m) for m in mod["missions"]],
            }
            for mod in spec["modules"]
        ],
    }


def main() -> None:
    trails = json.loads((ASSETS / "trails.json").read_text())
    studies_data = json.loads((ASSETS / "mission_studies.json").read_text())
    bank_data = json.loads((ASSETS / "nt_questions.json").read_text())

    # Êxodo: fio narrativo após Gênesis 12–50
    for t in trails:
        if t.get("slug") == "exodo":
            t["unlockAfter"] = "genesis-12-50"

    for spec in (ATOS, APOCALIPSE):
        apply_trail(trails, spec)
        missions = all_missions(spec)
        sections = {m["slug"] for m in missions}

        for m in missions:
            st = study_obj(m)
            if st:
                studies_data["studies"][st["slug"]] = st
                ref = st["passageRef"]
                studies_data.setdefault("verses", {})[ref] = st["passageText"]

        bank_data["questions"] = [
            q for q in bank_data["questions"] if not (q.get("trail") == spec["slug"])
        ]
        # also drop orphan old apo-boss-01 if trail changed — already cleared by trail filter
        bank_data["questions"].extend(expand_bank(spec["slug"], missions))

        print(
            f"{spec['slug']}: {len(missions)} missões, "
            f"{sum(1 for m in missions if not m.get('boss'))} studies, "
            f"{len(sections) * 15} perguntas"
        )

    # Remover study órfão do boss antigo se sobrar chave só — ok leave
    (ASSETS / "trails.json").write_text(json.dumps(trails, ensure_ascii=False, indent=2) + "\n")
    (ASSETS / "mission_studies.json").write_text(
        json.dumps(studies_data, ensure_ascii=False, indent=2) + "\n"
    )
    (ASSETS / "nt_questions.json").write_text(
        json.dumps(bank_data, ensure_ascii=False, indent=2) + "\n"
    )

    # Verificação rápida do caminho
    by = {t["slug"]: t.get("unlockAfter") for t in trails}
    path = [
        "genesis-1-11",
        "genesis-12-50",
        "exodo",
        "evangelhos",
        "atos",
        "cartas-paulo",
        "apocalipse",
    ]
    print("Caminho unlock:")
    for s in path:
        print(f"  {s} ← {by.get(s)}")


if __name__ == "__main__":
    main()
