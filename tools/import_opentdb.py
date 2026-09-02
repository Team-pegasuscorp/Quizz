#!/usr/bin/env python3
"""
Import trivia questions from OpenTDB into Quizz JSON files (FR + EN).

Translation: Argos Translate (offline, local neural MT).
  pip install -r tools/requirements.txt
  python tools/import_opentdb.py --install-models
  python tools/import_opentdb.py --amount 20

OpenTDB: https://opentdb.com/ — CC BY-SA 4.0 (credit in README / credits screen).
"""

from __future__ import annotations

import argparse
import html
import json
import re
import sys
import time
import urllib.parse
from pathlib import Path
from typing import Any

import requests

ROOT = Path(__file__).resolve().parents[1]
QUESTIONS_DIR = ROOT / "data" / "questions"
CATEGORIES_PATH = ROOT / "data" / "categories.json"
API_BASE = "https://opentdb.com/api.php"
TOKEN_API = "https://opentdb.com/api_token.php"
RATE_LIMIT_SEC = 5.1

DIFFICULTY_MAP = {"easy": 1, "medium": 2, "hard": 3}


def load_category_map() -> dict[str, int]:
    with CATEGORIES_PATH.open(encoding="utf-8") as handle:
        parsed = json.load(handle)
    result: dict[str, int] = {}
    for category_id, entry in parsed.items():
        opentdb_id = entry.get("opentdb_id")
        if opentdb_id is not None:
            result[category_id] = int(opentdb_id)
    return result


def ensure_argos_en_fr(install: bool) -> Any:
    try:
        import argostranslate.package
        import argostranslate.translate
    except ImportError as exc:
        raise SystemExit(
            "Argos Translate is required.\n"
            "  pip install -r tools/requirements.txt\n"
            "  python tools/import_opentdb.py --install-models"
        ) from exc

    installed = argostranslate.translate.get_installed_languages()
    en = next((lang for lang in installed if lang.code == "en"), None)
    fr = next((lang for lang in installed if lang.code == "fr"), None)
    if en and fr and en.get_translation(fr):
        return en.get_translation(fr)

    if not install:
        raise SystemExit(
            "English→French Argos model not installed.\n"
            "Run: python tools/import_opentdb.py --install-models"
        )

    print("Downloading Argos Translate en→fr model (one-time, ~50–100 MB)...")
    argostranslate.package.update_package_index()
    available = argostranslate.package.get_available_packages()
    package = next(
        (pkg for pkg in available if pkg.from_code == "en" and pkg.to_code == "fr"),
        None,
    )
    if package is None:
        raise SystemExit("Could not find Argos en→fr package in the index.")

    download_path = package.download()
    argostranslate.package.install_from_path(download_path)
    print("Model installed.")

    installed = argostranslate.translate.get_installed_languages()
    en = next(lang for lang in installed if lang.code == "en")
    fr = next(lang for lang in installed if lang.code == "fr")
    return en.get_translation(fr)


def decode_opentdb_text(value: str) -> str:
    if not value:
        return value
    decoded = urllib.parse.unquote(value)
    decoded = html.unescape(decoded)
    return decoded.strip()


def normalize_key(text: str) -> str:
    return re.sub(r"\s+", " ", text.lower().strip())


def request_session_token(session: requests.Session) -> str:
    response = session.get(TOKEN_API, params={"command": "request"}, timeout=30)
    response.raise_for_status()
    payload = response.json()
    if payload.get("response_code") != 0:
        raise RuntimeError(f"Token request failed: {payload}")
    return str(payload["token"])


def fetch_questions(
    session: requests.Session,
    *,
    category_id: int,
    amount: int,
    token: str | None,
) -> tuple[list[dict[str, Any]], str | None]:
    params: dict[str, Any] = {
        "amount": min(amount, 50),
        "category": category_id,
        "type": "multiple",
        "encode": "url3986",
    }
    if token:
        params["token"] = token

    time.sleep(RATE_LIMIT_SEC)
    response = session.get(API_BASE, params=params, timeout=30)
    response.raise_for_status()
    payload = response.json()
    code = payload.get("response_code")

    if code == 3 and token:
        # Stale token — caller may retry without token.
        return [], None
    if code == 4:
        print("  OpenTDB session exhausted for this category; resetting token.")
        if token:
            session.get(TOKEN_API, params={"command": "reset", "token": token}, timeout=30)
        return [], None
    if code != 0:
        raise RuntimeError(f"OpenTDB error {code}: {payload.get('response_message', payload)}")

    return list(payload.get("results", [])), token


def next_question_id(category: str, existing: list[dict[str, Any]]) -> str:
    max_num = 0
    prefix = f"{category}_"
    for item in existing:
        qid = str(item.get("id", ""))
        if qid.startswith(prefix):
            suffix = qid[len(prefix):]
            if suffix.isdigit():
                max_num = max(max_num, int(suffix))
    return f"{category}_{max_num + 1:03d}"


def load_category_file(category: str) -> dict[str, Any]:
    path = QUESTIONS_DIR / f"{category}.json"
    if not path.exists():
        return {"category": category, "questions": []}
    with path.open(encoding="utf-8") as handle:
        return json.load(handle)


def save_category_file(category: str, data: dict[str, Any]) -> Path:
    path = QUESTIONS_DIR / f"{category}.json"
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", encoding="utf-8") as handle:
        json.dump(data, handle, ensure_ascii=False, indent=2)
        handle.write("\n")
    return path


def build_explanation_en(correct: str) -> str:
    return f"The correct answer is: {correct}."


def convert_question(
    raw: dict[str, Any],
    *,
    category: str,
    question_id: str,
    translator: Any,
    dry_run: bool,
) -> dict[str, Any] | None:
    question_en = decode_opentdb_text(str(raw.get("question", "")))
    correct_en = decode_opentdb_text(str(raw.get("correct_answer", "")))
    incorrect_en = [
        decode_opentdb_text(str(x)) for x in raw.get("incorrect_answers", [])
    ]

    if not question_en or not correct_en or len(incorrect_en) != 3:
        return None

    choices_en = [correct_en] + incorrect_en
    # Stable shuffle per question id so imports are reproducible.
    import random

    rng = random.Random(question_id)
    indices = list(range(4))
    rng.shuffle(indices)
    choices_en = [choices_en[i] for i in indices]
    correct_index = choices_en.index(correct_en)

    explanation_en = build_explanation_en(correct_en)

    if dry_run:
        question_fr = f"[FR] {question_en}"
        choices_fr = [f"[FR] {c}" for c in choices_en]
        explanation_fr = f"[FR] {explanation_en}"
    else:
        question_fr = translator.translate(question_en)
        choices_fr = [translator.translate(choice) for choice in choices_en]
        explanation_fr = translator.translate(explanation_en)

    difficulty = DIFFICULTY_MAP.get(str(raw.get("difficulty", "medium")), 2)

    return {
        "id": question_id,
        "category": category,
        "difficulty": difficulty,
        "correct_index": correct_index,
        "locales": ["fr", "en"],
        "translations": {
            "en": {
                "text": question_en,
                "choices": choices_en,
                "explanation": explanation_en,
            },
            "fr": {
                "text": question_fr,
                "choices": choices_fr,
                "explanation": explanation_fr,
            },
        },
    }


def import_category(
    category: str,
    *,
    category_map: dict[str, int],
    amount: int,
    translator: Any,
    dry_run: bool,
    session: requests.Session,
) -> int:
    opentdb_id = category_map[category]
    data = load_category_file(category)
    existing: list[dict[str, Any]] = list(data.get("questions", []))
    seen = {
        normalize_key(q["translations"]["en"]["text"])
        for q in existing
        if q.get("translations", {}).get("en", {}).get("text")
    }

    token = request_session_token(session)
    remaining = amount
    added = 0

    print(f"\n[{category}] fetching up to {amount} questions (OpenTDB cat {opentdb_id})...")

    while remaining > 0:
        batch_size = min(remaining, 50)
        batch, token = fetch_questions(
            session,
            category_id=opentdb_id,
            amount=batch_size,
            token=token,
        )
        if not batch:
            if token is None:
                token = request_session_token(session)
                continue
            print(f"  No more unique questions available for {category}.")
            break

        for raw in batch:
            question_en = decode_opentdb_text(str(raw.get("question", "")))
            key = normalize_key(question_en)
            if not question_en or key in seen:
                continue

            question_id = next_question_id(category, existing)
            converted = convert_question(
                raw,
                category=category,
                question_id=question_id,
                translator=translator,
                dry_run=dry_run,
            )
            if converted is None:
                continue

            existing.append(converted)
            seen.add(key)
            added += 1
            remaining -= 1
            print(f"  + {question_id}: {question_en[:70]}{'…' if len(question_en) > 70 else ''}")

            if remaining <= 0:
                break

        if len(batch) < batch_size:
            break

    data["category"] = category
    data["questions"] = existing
    if not dry_run and added > 0:
        path = save_category_file(category, data)
        print(f"  Saved {added} new question(s) → {path.relative_to(ROOT)}")
    elif dry_run:
        print(f"  Dry run: would add {added} question(s).")
    else:
        print("  No new questions added.")

    return added


def parse_args() -> argparse.Namespace:
    category_map = load_category_map()
    parser = argparse.ArgumentParser(
        description="Import OpenTDB questions into Quizz JSON with offline FR translation (Argos)."
    )
    parser.add_argument(
        "--categories",
        default=",".join(category_map.keys()),
        help=f"Comma-separated category ids (default: {','.join(category_map.keys())})",
    )
    parser.add_argument(
        "--amount",
        type=int,
        default=15,
        help="Target new questions per category (default: 15)",
    )
    parser.add_argument(
        "--install-models",
        action="store_true",
        help="Download/install Argos Translate en→fr model and exit",
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Fetch and convert without translation or file writes",
    )
    return parser.parse_args(), category_map


def main() -> int:
    args, category_map = parse_args()

    if args.install_models:
        ensure_argos_en_fr(install=True)
        print("Ready. Run without --install-models to import.")
        return 0

    categories = [c.strip() for c in args.categories.split(",") if c.strip()]
    unknown = [c for c in categories if c not in category_map]
    if unknown:
        print(f"Unknown categories: {', '.join(unknown)}", file=sys.stderr)
        print(f"Available: {', '.join(category_map.keys())}", file=sys.stderr)
        return 1

    translator = None if args.dry_run else ensure_argos_en_fr(install=True)
    session = requests.Session()
    total = 0

    print("OpenTDB import — local translation via Argos Translate")
    if args.dry_run:
        print("(dry run: no Argos, no file writes)")

    for category in categories:
        total += import_category(
            category,
            category_map=category_map,
            amount=args.amount,
            translator=translator,
            dry_run=args.dry_run,
            session=session,
        )

    print(f"\nDone. {total} new question(s) across {len(categories)} category/categories.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
