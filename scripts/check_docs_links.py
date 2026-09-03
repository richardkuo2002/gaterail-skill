#!/usr/bin/env python3
"""Validate that internal Markdown links and referenced local paths exist.

Checks:
- Markdown links `[text](target)` in the scanned files.
- Inline-code spans that are unambiguously a reference into this repo (start
  with `.claude/`, `examples/`, `scripts/`, or `../../references/`) — e.g.
  `` `../../references/definition-of-done.md` ``.

Skipped, by design:
- External links (any scheme, e.g. `https://...`, `mailto:...`).
- Pure anchors (`#section`) and the anchor part of `path.md#section`.
- Inline-code spans that don't start with one of the repo-relative prefixes
  above — this deliberately excludes illustrative example paths used as
  prose inside skill docs (`src/path/to/file.ts`, `/api/createTask`,
  `tasks/todo.md`, `./gradlew`, ...), which document a pattern, not a file
  in this repository.
- Any candidate containing `<`, `>`, or `*` — a templated placeholder
  (`.claude/skills/<name>/SKILL.md`) or a glob (`../../references/*.md`),
  not a literal path.

Standard library only. Exits 1 and prints every broken reference if any are
found; exits 0 otherwise.
"""
from __future__ import annotations

import pathlib
import re
import sys

ROOT = pathlib.Path(__file__).resolve().parent.parent

SCAN_FILES = [
    "README.md",
    "README.zh-TW.md",
    "README.ja.md",
    "README.ko.md",
    "CONTRIBUTING.md",
    "SECURITY.md",
    "ROADMAP.md",
    "CHANGELOG.md",
    "examples/python-cli/README.md",
    *sorted(str(p.relative_to(ROOT)) for p in ROOT.glob(".claude/skills/*/SKILL.md")),
]

MD_LINK_RE = re.compile(r"\[[^\]]*\]\(([^)\s]+)\)")
INLINE_CODE_RE = re.compile(r"`([^`\s]+)`")


def is_external(target: str) -> bool:
    return bool(re.match(r"^[a-zA-Z][a-zA-Z0-9+.-]*://", target)) or target.startswith(
        "mailto:"
    )


REPO_RELATIVE_PREFIXES = (".claude/", "examples/", "scripts/", "../../references/")


def looks_like_path(candidate: str) -> bool:
    if is_external(candidate) or candidate.startswith("#"):
        return False
    if any(ch in candidate for ch in "<>*"):
        return False
    return candidate.startswith(REPO_RELATIVE_PREFIXES)


def strip_anchor(target: str) -> str:
    return target.split("#", 1)[0]


def check_file(relpath: str) -> list[str]:
    path = ROOT / relpath
    errors = []
    if not path.is_file():
        return [f"{relpath}: file listed for checking does not exist"]

    text = path.read_text(encoding="utf-8")
    directory = path.parent

    candidates: list[str] = []
    for match in MD_LINK_RE.finditer(text):
        candidates.append(match.group(1))
    for match in INLINE_CODE_RE.finditer(text):
        code = match.group(1)
        if looks_like_path(code):
            candidates.append(code)

    seen = set()
    for raw in candidates:
        if is_external(raw) or raw.startswith("#"):
            continue
        target = strip_anchor(raw)
        if not target:
            continue
        if target in seen:
            continue
        seen.add(target)
        resolved = (directory / target).resolve()
        if not resolved.exists():
            errors.append(f"{relpath}: broken reference '{raw}' -> {resolved}")

    return errors


def main() -> int:
    all_errors: list[str] = []
    checked = 0
    for relpath in SCAN_FILES:
        all_errors.extend(check_file(relpath))
        checked += 1

    if all_errors:
        print(f"Found {len(all_errors)} broken reference(s) across {checked} file(s):")
        for err in all_errors:
            print(f"  {err}")
        return 1

    print(f"All references OK across {checked} file(s).")
    return 0


if __name__ == "__main__":
    sys.exit(main())
