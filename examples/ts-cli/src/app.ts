#!/usr/bin/env node
/**
 * A tiny status-report CLI, used as GateRail's worked example
 * (TypeScript/Node version of examples/python-cli's app.py).
 *
 * Usage:
 *   node dist/app.js report          human-readable report (default)
 *   node dist/app.js report --json   same data, as JSON
 *
 * No third-party runtime dependency: node:util's parseArgs (stdlib) plays
 * the role argparse plays in the Python example.
 */
import { parseArgs } from "node:util";

type Status = "ok" | "warn" | "fail";

interface Check {
  name: string;
  status: Status;
}

// Fixed, deterministic sample data — no file or network I/O, so the report
// is the same every run. A real tool would compute this from actual state.
const CHECKS: readonly Check[] = [
  { name: "specification gate", status: "ok" },
  { name: "delivery gate", status: "ok" },
  { name: "changelog", status: "warn" },
];

interface Counts {
  ok: number;
  warn: number;
  fail: number;
  total: number;
}

function summarize(checks: readonly Check[]): Counts {
  const counts: Counts = { ok: 0, warn: 0, fail: 0, total: checks.length };
  for (const check of checks) {
    counts[check.status] += 1;
  }
  return counts;
}

function renderText(counts: Counts): string {
  const lines = ["GateRail status report"];
  for (const key of ["ok", "warn", "fail"] as const) {
    lines.push(`  ${key}: ${counts[key]}`);
  }
  lines.push(`Total: ${counts.total}`);
  return lines.join("\n");
}

function renderJson(counts: Counts): string {
  const ordered: Record<string, number> = {};
  for (const key of Object.keys(counts).sort()) {
    ordered[key] = counts[key as keyof Counts];
  }
  return JSON.stringify(ordered);
}

function main(argv: string[]): number {
  let positionals: string[];
  let json: boolean;
  try {
    const parsed = parseArgs({
      args: argv,
      allowPositionals: true,
      options: { json: { type: "boolean", default: false } },
    });
    positionals = parsed.positionals;
    json = parsed.values.json ?? false;
  } catch (err) {
    process.stderr.write(`error: ${(err as Error).message}\n`);
    return 2;
  }

  const command = positionals[0];
  if (command === undefined) {
    process.stderr.write("error: a command is required (expected: report)\n");
    return 2;
  }
  if (command !== "report") {
    process.stderr.write(`error: unknown command: ${command}\n`);
    return 2;
  }

  const counts = summarize(CHECKS);
  console.log(json ? renderJson(counts) : renderText(counts));
  return 0;
}

process.exitCode = main(process.argv.slice(2));
