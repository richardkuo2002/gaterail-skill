"""Tests for app.py.

Runs the CLI as a subprocess (not by importing it) so these tests exercise
exactly what a user invokes: `python app.py ...`, its stdout, its stderr,
and its exit status. Standard library only (unittest + subprocess).
"""
from __future__ import annotations

import json
import pathlib
import subprocess
import sys
import unittest

APP = str(pathlib.Path(__file__).parent / "app.py")


def run_cli(*args: str) -> subprocess.CompletedProcess:
    return subprocess.run(
        [sys.executable, APP, *args],
        capture_output=True,
        text=True,
    )


class TestReportTextOutput(unittest.TestCase):
    def test_default_output_is_human_readable_text(self):
        result = run_cli("report")
        self.assertEqual(result.returncode, 0)
        self.assertIn("GateRail status report", result.stdout)
        self.assertIn("Total: 3", result.stdout)
        self.assertEqual(result.stderr, "")

    def test_text_output_is_not_valid_json(self):
        result = run_cli("report")
        with self.assertRaises(json.JSONDecodeError):
            json.loads(result.stdout)


class TestReportJsonOutput(unittest.TestCase):
    def test_json_flag_produces_valid_json(self):
        result = run_cli("report", "--json")
        self.assertEqual(result.returncode, 0)
        self.assertEqual(result.stderr, "")
        payload = json.loads(result.stdout)
        self.assertEqual(payload["total"], 3)
        self.assertIn("ok", payload)
        self.assertIn("warn", payload)
        self.assertIn("fail", payload)

    def test_json_and_text_report_the_same_counts(self):
        text_result = run_cli("report")
        json_result = run_cli("report", "--json")
        payload = json.loads(json_result.stdout)
        self.assertIn(f"Total: {payload['total']}", text_result.stdout)
        self.assertIn(f"ok: {payload['ok']}", text_result.stdout)


class TestInvalidArguments(unittest.TestCase):
    def test_missing_command_exits_nonzero_with_stderr(self):
        result = run_cli()
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(result.stdout, "")
        self.assertNotEqual(result.stderr, "")

    def test_unknown_command_exits_nonzero_with_stderr(self):
        result = run_cli("bogus")
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(result.stdout, "")
        self.assertIn("invalid choice", result.stderr)

    def test_unknown_flag_on_report_exits_nonzero_with_stderr(self):
        result = run_cli("report", "--bogus")
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(result.stdout, "")
        self.assertNotEqual(result.stderr, "")


if __name__ == "__main__":
    unittest.main()
