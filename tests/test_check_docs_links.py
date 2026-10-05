#!/usr/bin/env python3
"""Tests for scripts/check_docs_links.py.

Standard library only (unittest), matching examples/python-cli's test style.
Loads the script by path (it's not an importable package) and exercises its
pure functions plus check_file() against a scratch fixture tree — never the
real repo content, so these tests can't flake on documentation edits.
"""
from __future__ import annotations

import importlib.util
import pathlib
import sys
import tempfile
import unittest

_SCRIPT_PATH = pathlib.Path(__file__).resolve().parent.parent / "scripts" / "check_docs_links.py"
_spec = importlib.util.spec_from_file_location("check_docs_links", _SCRIPT_PATH)
check_docs_links = importlib.util.module_from_spec(_spec)
sys.modules["check_docs_links"] = check_docs_links
_spec.loader.exec_module(check_docs_links)


class TestIsExternal(unittest.TestCase):
    def test_scheme_links_are_external(self):
        self.assertTrue(check_docs_links.is_external("https://example.com"))
        self.assertTrue(check_docs_links.is_external("mailto:a@example.com"))

    def test_relative_path_is_not_external(self):
        self.assertFalse(check_docs_links.is_external("docs/compatibility.md"))


class TestLooksLikePath(unittest.TestCase):
    def test_repo_relative_prefix_is_a_path(self):
        self.assertTrue(check_docs_links.looks_like_path("scripts/check_docs_links.py"))

    def test_illustrative_example_path_is_not_a_path(self):
        # Prose inside skill docs, e.g. `src/path/to/file.ts` — documents a
        # pattern, not a file in this repository.
        self.assertFalse(check_docs_links.looks_like_path("src/path/to/file.ts"))

    def test_templated_placeholder_is_not_a_path(self):
        self.assertFalse(check_docs_links.looks_like_path(".claude/skills/<name>/SKILL.md"))

    def test_glob_is_not_a_path(self):
        self.assertFalse(check_docs_links.looks_like_path("../../references/*.md"))


class TestCheckFile(unittest.TestCase):
    def setUp(self):
        self._tmp = tempfile.TemporaryDirectory()
        self.root = pathlib.Path(self._tmp.name)
        self.addCleanup(self._tmp.cleanup)

    def write(self, relpath: str, text: str) -> None:
        path = self.root / relpath
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(text, encoding="utf-8")

    def test_missing_scanned_file_is_an_error(self):
        errors = check_docs_links.check_file_in(self.root, "NOPE.md")
        self.assertEqual(len(errors), 1)
        self.assertIn("does not exist", errors[0])

    def test_valid_markdown_link_has_no_error(self):
        self.write("CHANGELOG.md", "[root](README.md)\n")
        self.write("README.md", "# hi\n")
        self.assertEqual(check_docs_links.check_file_in(self.root, "CHANGELOG.md"), [])

    def test_broken_markdown_link_is_reported(self):
        self.write("CHANGELOG.md", "[gone](NOWHERE.md)\n")
        errors = check_docs_links.check_file_in(self.root, "CHANGELOG.md")
        self.assertEqual(len(errors), 1)
        self.assertIn("NOWHERE.md", errors[0])

    def test_external_and_anchor_links_are_skipped(self):
        self.write("CHANGELOG.md", "[ext](https://example.com) [anchor](#top)\n")
        self.assertEqual(check_docs_links.check_file_in(self.root, "CHANGELOG.md"), [])

    def test_broken_repo_relative_inline_code_is_reported(self):
        self.write("CHANGELOG.md", "see `examples/missing/README.md`\n")
        errors = check_docs_links.check_file_in(self.root, "CHANGELOG.md")
        self.assertEqual(len(errors), 1)

    def test_illustrative_inline_code_is_not_checked(self):
        # Doesn't start with a repo-relative prefix — a pattern, not a path.
        self.write("CHANGELOG.md", "run `./gradlew build`\n")
        self.assertEqual(check_docs_links.check_file_in(self.root, "CHANGELOG.md"), [])


class TestScanFilesScopeIsConsistent(unittest.TestCase):
    """council review, 2026-10: docs/ and examples/*/README.md must be
    globbed like .claude/skills and .claude/references, not hand-maintained,
    or a new file in either silently never gets checked."""

    def test_new_docs_file_is_picked_up_without_editing_the_script(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = pathlib.Path(tmp)
            (root / "docs").mkdir()
            (root / "docs" / "new-topic.md").write_text("# new\n", encoding="utf-8")
            (root / "docs" / "compatibility.md").write_text("# compat\n", encoding="utf-8")
            found = {p.name for p in root.glob("docs/*.md")}
            self.assertEqual(found, {"new-topic.md", "compatibility.md"})

    def test_new_example_readme_is_picked_up_without_editing_the_script(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = pathlib.Path(tmp)
            for name in ("python-cli", "ts-cli", "rust-cli"):
                d = root / "examples" / name
                d.mkdir(parents=True)
                (d / "README.md").write_text("# example\n", encoding="utf-8")
            found = sorted(str(p.relative_to(root)) for p in root.glob("examples/*/README.md"))
            self.assertEqual(
                found,
                ["examples/python-cli/README.md", "examples/rust-cli/README.md", "examples/ts-cli/README.md"],
            )


if __name__ == "__main__":
    unittest.main()
