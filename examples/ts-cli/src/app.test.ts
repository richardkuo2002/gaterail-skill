/**
 * Tests for app.ts (run against the compiled dist/app.js).
 *
 * Runs the CLI as a subprocess (not by importing it) so these tests
 * exercise exactly what a user invokes — mirrors examples/python-cli's
 * test_app.py by design, so the two examples are directly comparable.
 * Standard library only: node:test + node:assert + node:child_process.
 */
import { test } from "node:test";
import assert from "node:assert/strict";
import { spawnSync } from "node:child_process";
import path from "node:path";
import { fileURLToPath } from "node:url";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const APP = path.join(__dirname, "app.js");

function runCli(...args: string[]) {
  const result = spawnSync(process.execPath, [APP, ...args], {
    encoding: "utf8",
  });
  return {
    stdout: result.stdout ?? "",
    stderr: result.stderr ?? "",
    status: result.status ?? 1,
  };
}

test("default output is human-readable text", () => {
  const { stdout, stderr, status } = runCli("report");
  assert.equal(status, 0);
  assert.match(stdout, /GateRail status report/);
  assert.match(stdout, /Total: 3/);
  assert.equal(stderr, "");
});

test("text output is not valid JSON", () => {
  const { stdout } = runCli("report");
  assert.throws(() => JSON.parse(stdout));
});

test("--json flag produces valid JSON", () => {
  const { stdout, stderr, status } = runCli("report", "--json");
  assert.equal(status, 0);
  assert.equal(stderr, "");
  const payload = JSON.parse(stdout);
  assert.equal(payload.total, 3);
  assert.ok("ok" in payload);
  assert.ok("warn" in payload);
  assert.ok("fail" in payload);
});

test("json and text report the same counts", () => {
  const text = runCli("report").stdout;
  const payload = JSON.parse(runCli("report", "--json").stdout);
  assert.match(text, new RegExp(`Total: ${payload.total}`));
  assert.match(text, new RegExp(`ok: ${payload.ok}`));
});

test("missing command exits non-zero with stderr", () => {
  const { stdout, stderr, status } = runCli();
  assert.notEqual(status, 0);
  assert.equal(stdout, "");
  assert.notEqual(stderr, "");
});

test("unknown command exits non-zero with stderr", () => {
  const { stdout, stderr, status } = runCli("bogus");
  assert.notEqual(status, 0);
  assert.equal(stdout, "");
  assert.match(stderr, /unknown command/);
});

test("unknown flag exits non-zero with stderr", () => {
  const { stdout, stderr, status } = runCli("report", "--bogus");
  assert.notEqual(status, 0);
  assert.equal(stdout, "");
  assert.notEqual(stderr, "");
});
