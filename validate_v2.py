#!/usr/bin/env python3
"""
validate_v2.py — Validador do banco de perguntas V2 do STWAY.

Uso:
    python validate_v2.py caminho/para/missao_ou_trilha.json [outro.json ...]
    python validate_v2.py caminho/para/pasta_com_jsons/

O que valida (por missão, identificada por trail+section):
  - Exatamente 18 perguntas: 6 gestos x 3 modos (semente/caminhada/profundezas)
  - skill correto por modo (observe/understand/interpret)
  - Nenhum gesto faltando ou duplicado dentro do mesmo modo
  - true_false: enunciado não é pergunta (não termina em "?", não começa com
    interrogativos "o que"/"qual"/"quem"/"como"/"por que"); options = true/false
  - tap: exatamente 3 options, cada texto de opção aparece literalmente
    dentro do passageText (case-insensitive); template contém "___"
  - complete: template contém "___"; 3 options
  - choice: 4 options; feedbackWrong cobre todas as opções erradas
  - order: 3 options; correctOrder é permutação válida dos ids; nenhuma
    opção termina em "…" ou "..." (peça cortada)
  - connect: passageA e passageB presentes; 3 options
  - Nenhum "question" duplicado dentro do mesmo (trail, section, difficulty)
  - evidence não vazio; learningObjective presente; feedbackCorrect <= 100 chars

Saída: relatório por missão com OK ou lista de problemas, e resumo final.
Exit code 0 se tudo OK, 1 se houver qualquer erro (útil para CI / hooks).
"""

import json
import sys
import os
import re
from collections import defaultdict

EXPECTED_SKILL = {
    "semente": "observe",
    "caminhada": "understand",
    "profundezas": "interpret",
}
EXPECTED_TYPES = {"true_false", "tap", "choice", "order", "complete", "connect"}
DIFFICULTIES = ["semente", "caminhada", "profundezas"]

INTERROGATIVE_START = re.compile(
    r"^\s*(o que|qual|quais|quem|como|por que|porque|onde|quando)\b",
    re.IGNORECASE,
)


def load_questions(paths):
    """Carrega e achata perguntas de um ou mais arquivos/pastas JSON.
    Aceita: array de perguntas na raiz, ou objeto com chave 'questions'/'bank'."""
    questions = []
    files = []
    for p in paths:
        if os.path.isdir(p):
            for root, _, names in os.walk(p):
                for n in names:
                    if n.endswith(".json"):
                        files.append(os.path.join(root, n))
        else:
            files.append(p)

    for f in files:
        with open(f, "r", encoding="utf-8") as fh:
            data = json.load(fh)
        if isinstance(data, list):
            questions.extend(data)
        elif isinstance(data, dict):
            if "questions" in data:
                questions.extend(data["questions"])
            elif "bank" in data:
                questions.extend(data["bank"])
            else:
                print(f"[aviso] {f}: objeto sem 'questions'/'bank', ignorado.")
    return questions


def word_in_passage(option_text, passage_text):
    if not passage_text:
        return False
    return option_text.strip().lower() in passage_text.lower()


def validate_mission(key, items):
    """items = lista de perguntas de uma única missão (trail, section)."""
    errors = []

    if len(items) != 18:
        errors.append(f"esperado 18 perguntas, encontrado {len(items)}")

    by_diff = defaultdict(list)
    for q in items:
        by_diff[q.get("difficulty")].append(q)

    for diff in DIFFICULTIES:
        group = by_diff.get(diff, [])
        if len(group) != 6:
            errors.append(f"[{diff}] esperado 6 perguntas, encontrado {len(group)}")

        types_seen = [q.get("type") for q in group]
        missing = EXPECTED_TYPES - set(types_seen)
        dup = [t for t in set(types_seen) if types_seen.count(t) > 1]
        if missing:
            errors.append(f"[{diff}] gestos faltando: {sorted(missing)}")
        if dup:
            errors.append(f"[{diff}] gestos duplicados: {sorted(dup)}")

        expected_skill = EXPECTED_SKILL[diff]
        for q in group:
            if q.get("skill") != expected_skill:
                errors.append(
                    f"[{diff}/{q.get('type')}] skill='{q.get('skill')}' "
                    f"esperado '{expected_skill}'"
                )

        # checagens por tipo
        for q in group:
            t = q.get("type")
            qid = q.get("id", "?")
            question_text = q.get("question", "")

            if t == "true_false":
                if question_text.strip().endswith("?") or INTERROGATIVE_START.match(question_text):
                    errors.append(f"[{qid}] true_false parece pergunta, não afirmação: '{question_text}'")
                opt_ids = {o.get("id") for o in q.get("options", [])}
                if opt_ids != {"true", "false"}:
                    errors.append(f"[{qid}] true_false options inválidas: {opt_ids}")
                if q.get("correctOptionId") not in {"true", "false"}:
                    errors.append(f"[{qid}] correctOptionId inválido para true_false")

            elif t == "tap":
                opts = q.get("options", [])
                if len(opts) != 3:
                    errors.append(f"[{qid}] tap deveria ter 3 options, tem {len(opts)}")
                passage = q.get("passageText", "")
                if "___" not in q.get("template", ""):
                    errors.append(f"[{qid}] tap sem '___' no template")
                texts = [o.get("text", "").strip().lower() for o in opts]
                if len(texts) != len(set(texts)):
                    errors.append(f"[{qid}] tap com opções duplicadas: {texts}")
                for o in opts:
                    if len(o.get("text", "").split()) > 3:
                        errors.append(f"[{qid}] opção de tap com mais de 3 palavras: '{o.get('text')}'")
                    if not word_in_passage(o.get("text", ""), passage):
                        errors.append(f"[{qid}] opção de tap '{o.get('text')}' não existe no passageText")

            elif t == "complete":
                if "___" not in q.get("template", ""):
                    errors.append(f"[{qid}] complete sem '___' no template")
                if len(q.get("options", [])) != 3:
                    errors.append(f"[{qid}] complete deveria ter 3 options")

            elif t == "choice":
                opts = q.get("options", [])
                if len(opts) != 4:
                    errors.append(f"[{qid}] choice deveria ter 4 options, tem {len(opts)}")
                correct = q.get("correctOptionId")
                fb_wrong = q.get("feedbackWrong", {})
                wrong_ids = {o["id"] for o in opts if o["id"] != correct}
                missing_fb = wrong_ids - set(fb_wrong.keys())
                if missing_fb:
                    errors.append(f"[{qid}] choice sem feedbackWrong para: {sorted(missing_fb)}")
                for o in opts:
                    if len(o.get("text", "")) > 90:
                        errors.append(f"[{qid}] opção de choice muito longa (>90 chars): '{o['text'][:40]}...'")

            elif t == "order":
                opts = q.get("options", [])
                if len(opts) != 3:
                    errors.append(f"[{qid}] order deveria ter 3 options, tem {len(opts)}")
                ids = [o["id"] for o in opts]
                corr = q.get("correctOrder", [])
                if sorted(corr) != sorted(ids):
                    errors.append(f"[{qid}] correctOrder {corr} não é permutação de ids {ids}")
                for o in opts:
                    if o.get("text", "").rstrip().endswith(("…", "...")):
                        errors.append(f"[{qid}] peça de order cortada (termina em reticências): '{o['text'][:40]}'")

            elif t == "connect":
                if not q.get("passageA") or not q.get("passageB"):
                    errors.append(f"[{qid}] connect sem passageA/passageB")
                if len(q.get("options", [])) != 3:
                    errors.append(f"[{qid}] connect deveria ter 3 options")

            # checagens gerais
            if not q.get("evidence"):
                errors.append(f"[{qid}] evidence vazio")
            if not q.get("learningObjective"):
                errors.append(f"[{qid}] learningObjective ausente")
            fc = q.get("feedbackCorrect", "")
            if len(fc) > 100:
                errors.append(f"[{qid}] feedbackCorrect > 100 chars ({len(fc)})")

        # enunciados duplicados dentro do mesmo trail+section+difficulty
        seen = {}
        for q in group:
            qt = q.get("question", "").strip().lower()
            if qt in seen:
                errors.append(f"[{diff}] enunciado duplicado: '{q.get('question')}' ({seen[qt]} / {q.get('id')})")
            else:
                seen[qt] = q.get("id")

    return errors


def main():
    if len(sys.argv) < 2:
        print(__doc__)
        sys.exit(1)

    questions = load_questions(sys.argv[1:])
    if not questions:
        print("Nenhuma pergunta encontrada nos arquivos informados.")
        sys.exit(1)

    missions = defaultdict(list)
    for q in questions:
        key = (q.get("trail"), q.get("section"))
        missions[key].append(q)

    total_errors = 0
    for key, items in sorted(missions.items()):
        errors = validate_mission(key, items)
        status = "OK" if not errors else f"{len(errors)} problema(s)"
        print(f"\n=== {key[0]} / {key[1]} — {status} ===")
        for e in errors:
            print(f"  - {e}")
        total_errors += len(errors)

    print(f"\n{'='*60}")
    print(f"Missões verificadas: {len(missions)}")
    print(f"Perguntas verificadas: {len(questions)}")
    print(f"Total de problemas: {total_errors}")
    print(f"{'='*60}")

    sys.exit(1 if total_errors else 0)


if __name__ == "__main__":
    main()