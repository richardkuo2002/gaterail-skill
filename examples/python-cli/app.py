#!/usr/bin/env python3
"""A tiny status-report CLI, used as GateRail's worked example.

Usage:
    python app.py report          human-readable report (default)
    python app.py report --json   same data, as JSON

Standard library only.
"""
from __future__ import annotations

import argparse
import json
import sys

# Fixed, deterministic sample data — no file or network I/O, so the report
# is the same every run. A real tool would compute this from actual state.
_CHECKS = (
    {"name": "specification gate", "status": "ok"},
    {"name": "delivery gate", "status": "ok"},
    {"name": "changelog", "status": "warn"},
)


def _summarize(checks):
    counts = {"ok": 0, "warn": 0, "fail": 0}
    for check in checks:
        counts[check["status"]] += 1
    counts["total"] = len(checks)
    return counts


def _render_text(counts):
    lines = ["GateRail status report"]
    for key in ("ok", "warn", "fail"):
        lines.append(f"  {key}: {counts[key]}")
    lines.append(f"Total: {counts['total']}")
    return "\n".join(lines)


def _render_json(counts):
    return json.dumps(counts, sort_keys=True)


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(prog="app.py")
    subparsers = parser.add_subparsers(dest="command", required=True)

    report = subparsers.add_parser("report", help="print a status report")
    report.add_argument(
        "--json", action="store_true", help="print the report as JSON"
    )

    return parser


def main(argv=None) -> int:
    parser = build_parser()
    args = parser.parse_args(argv)

    if args.command == "report":
        counts = _summarize(_CHECKS)
        if args.json:
            print(_render_json(counts))
        else:
            print(_render_text(counts))
        return 0

    # argparse's `required=True` on the subparser already rejects a missing
    # or unknown command before we get here; this is unreachable in practice.
    parser.error(f"unknown command: {args.command}")
    return 2


if __name__ == "__main__":
    sys.exit(main())
