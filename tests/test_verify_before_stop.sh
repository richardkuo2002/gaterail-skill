#!/usr/bin/env bash
# Scripted tests for .claude/hooks/verify-before-stop.sh: runs it directly
# (the same way Claude Code's Stop event would) against a scratch git repo,
# asserting on its exit code and stdout JSON. Mirrors test_install.sh's
# scratch-dir pattern.
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
HOOK="$REPO/.claude/hooks/verify-before-stop.sh"

fail() { echo "FAIL: $1" >&2; exit 1; }
pass() { echo "ok: $1"; }

# Fresh scratch git repo with one commit, leaves $SCRATCH set, restores cwd.
new_repo() {
  SCRATCH="$(mktemp -d)"
  (
    cd "$SCRATCH"
    git init -q
    git config user.email t@t.com
    git config user.name t
    echo "hello" >file.txt
    git add . && git commit -q -m init
    mkdir -p .claude/hooks
  )
}

run_hook() {
  CLAUDE_PROJECT_DIR="$SCRATCH" bash "$HOOK"
}

retry_count_in_state() {
  sed -n '3p' "$SCRATCH/.claude/hooks/.gaterail-state" 2>/dev/null || echo ""
}

# ---- no config file: no-op -------------------------------------------------
test_no_config_is_noop() {
  new_repo
  local out status
  out="$(run_hook)"; status=$?
  [ "$status" -eq 0 ] || fail "no-config: expected exit 0, got $status"
  [ -z "$out" ] || fail "no-config: expected no output, got: $out"
  pass "no config file is a silent no-op"
}

# ---- config with only comments/blank lines: no-op --------------------------
test_comment_only_config_is_noop() {
  new_repo
  printf '# nothing here\n\n' >"$SCRATCH/.claude/hooks/gaterail-checks.txt"
  local out status
  out="$(run_hook)"; status=$?
  [ "$status" -eq 0 ] || fail "comment-only config: expected exit 0, got $status"
  [ -z "$out" ] || fail "comment-only config: expected no output, got: $out"
  pass "comment-only config is a silent no-op"
}

# ---- passing check: silent, writes state -----------------------------------
test_passing_check_is_silent_and_writes_state() {
  new_repo
  printf '.\ttrue\n' >"$SCRATCH/.claude/hooks/gaterail-checks.txt"
  local out status
  out="$(run_hook)"; status=$?
  [ "$status" -eq 0 ] || fail "passing check: expected exit 0, got $status"
  [ -z "$out" ] || fail "passing check: expected no output, got: $out"
  [ -f "$SCRATCH/.claude/hooks/.gaterail-state" ] || fail "passing check: expected state file to be written"
  pass "a passing check is silent and records state"
}

# ---- unchanged diff: check is not re-run -----------------------------------
test_unchanged_diff_skips_rerun() {
  new_repo
  printf '.\ttrue\n' >"$SCRATCH/.claude/hooks/gaterail-checks.txt"
  run_hook >/dev/null
  # Swap in a command that would prove it ran, by writing a marker file —
  # if the hook actually invoked this, the marker would exist afterward.
  printf '.\ttouch ran.marker; false\n' >"$SCRATCH/.claude/hooks/gaterail-checks.txt"
  run_hook >/dev/null
  [ ! -e "$SCRATCH/ran.marker" ] || fail "unchanged diff: check was re-run when nothing changed"
  pass "unchanged diff since last pass skips re-running checks"
}

# ---- failing check: blocks with JSON decision, valid JSON ------------------
test_failing_check_blocks_with_valid_json() {
  new_repo
  echo "change" >>"$SCRATCH/file.txt"
  printf '.\tfalse\n' >"$SCRATCH/.claude/hooks/gaterail-checks.txt"
  local out status
  out="$(run_hook)"; status=$?
  [ "$status" -eq 0 ] || fail "failing check: expected exit 0 (block is via JSON, not exit code), got $status"
  echo "$out" | python3 -c "
import json, sys
d = json.load(sys.stdin)
assert d['decision'] == 'block', d
assert 'false' in d['reason'], d
assert 'exit 1' in d['reason'], d
" || fail "failing check: stdout was not the expected block JSON: $out"
  pass "a failing check on a changed diff blocks with valid JSON"
}

# ---- JSON escaping: quotes/backslashes/newlines in output don't break JSON -
test_failure_output_with_special_chars_stays_valid_json() {
  new_repo
  echo "change" >>"$SCRATCH/file.txt"
  printf '.\techo '"'"'said "hi\\\\there"'"'"'; echo line2; exit 1\n' >"$SCRATCH/.claude/hooks/gaterail-checks.txt"
  local out
  out="$(run_hook)"
  echo "$out" | python3 -c "
import json, sys
d = json.load(sys.stdin)
assert d['decision'] == 'block', d
" || fail "special-char output broke the JSON: $out"
  pass "quotes/backslashes/newlines in check output don't break the JSON"
}

# ---- retry cap: blocks 3 times, then lets the stop proceed -----------------
test_retry_cap_then_allows_stop() {
  new_repo
  echo "change" >>"$SCRATCH/file.txt"
  printf '.\tfalse\n' >"$SCRATCH/.claude/hooks/gaterail-checks.txt"

  for i in 1 2 3; do
    local out
    out="$(run_hook)"
    echo "$out" | grep -q '"decision":"block"' || fail "retry $i: expected a block decision, got: $out"
    [ "$(retry_count_in_state)" = "$i" ] || fail "retry $i: expected retry count $i, got $(retry_count_in_state)"
  done

  local out status
  out="$(run_hook 2>&1)"; status=$?
  [ "$status" -eq 0 ] || fail "retry cap: expected exit 0 on the 4th attempt, got $status"
  echo "$out" | grep -qi "still failing after 3 attempts" || fail "retry cap: expected a give-up warning, got: $out"
  ! echo "$out" | grep -q '"decision":"block"' || fail "retry cap: should not still be blocking on the 4th attempt"
  pass "blocks for 3 attempts on an unchanged diff, then lets the turn end with a warning"
}

# ---- a new diff resets the retry counter -----------------------------------
test_new_diff_resets_retry_counter() {
  new_repo
  echo "change1" >>"$SCRATCH/file.txt"
  printf '.\tfalse\n' >"$SCRATCH/.claude/hooks/gaterail-checks.txt"
  run_hook >/dev/null
  run_hook >/dev/null
  [ "$(retry_count_in_state)" = "2" ] || fail "setup: expected retry count 2 before the new diff"

  echo "change2" >>"$SCRATCH/file.txt"
  run_hook >/dev/null
  [ "$(retry_count_in_state)" = "1" ] || fail "new diff: expected retry count reset to 1, got $(retry_count_in_state)"
  pass "a new diff resets the retry counter instead of accumulating"
}

# ---- recovery: a later passing check clears the failure state -------------
test_recovery_clears_failure_state() {
  new_repo
  echo "change1" >>"$SCRATCH/file.txt"
  printf '.\tfalse\n' >"$SCRATCH/.claude/hooks/gaterail-checks.txt"
  run_hook >/dev/null

  printf '.\ttrue\n' >"$SCRATCH/.claude/hooks/gaterail-checks.txt"
  echo "change2" >>"$SCRATCH/file.txt"
  local out status
  out="$(run_hook)"; status=$?
  [ "$status" -eq 0 ] || fail "recovery: expected exit 0, got $status"
  [ -z "$out" ] || fail "recovery: expected no output once the check passes, got: $out"
  [ "$(retry_count_in_state)" = "0" ] || fail "recovery: expected retry count reset to 0, got $(retry_count_in_state)"
  pass "a passing check after failures clears the retry/failure state"
}

# ---- multiple checks: reports the one that actually failed -----------------
test_multiple_checks_reports_the_failing_one() {
  new_repo
  mkdir -p "$SCRATCH/sub"
  echo "change" >>"$SCRATCH/file.txt"
  printf '.\ttrue\nsub\tfalse\n' >"$SCRATCH/.claude/hooks/gaterail-checks.txt"
  local out
  out="$(run_hook)"
  echo "$out" | grep -q '"reason":"sub:' || fail "expected the failure to be attributed to 'sub', got: $out"
  pass "with multiple checks, the failure message names the one that actually failed"
}

# ---- not a git repo: fails open, never blocks ------------------------------
test_non_git_repo_fails_open() {
  SCRATCH="$(mktemp -d)"
  mkdir -p "$SCRATCH/.claude/hooks"
  printf '.\tfalse\n' >"$SCRATCH/.claude/hooks/gaterail-checks.txt"
  local out status
  out="$(run_hook)"; status=$?
  [ "$status" -eq 0 ] || fail "non-git repo: expected exit 0 (fail open), got $status"
  [ -z "$out" ] || fail "non-git repo: expected no output, got: $out"
  pass "a non-git project fails open instead of blocking"
}

test_no_config_is_noop
test_comment_only_config_is_noop
test_passing_check_is_silent_and_writes_state
test_unchanged_diff_skips_rerun
test_failing_check_blocks_with_valid_json
test_failure_output_with_special_chars_stays_valid_json
test_retry_cap_then_allows_stop
test_new_diff_resets_retry_counter
test_recovery_clears_failure_state
test_multiple_checks_reports_the_failing_one
test_non_git_repo_fails_open

echo
echo "All verify-before-stop.sh scripted tests passed."
