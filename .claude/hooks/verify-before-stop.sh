#!/usr/bin/env bash
# GateRail delivery-gate Stop hook.
#
# Wired via .claude/settings.json's "Stop" hook (see
# scripts/install-verify-hook.sh). Claude Code invokes this script right
# before ending a turn, with a JSON event on stdin (we don't need to parse
# it — see "What we don't read from stdin" below) and waits for either:
#   - exit 0, no stdout JSON          -> stop proceeds
#   - exit 0, {"decision":"block",…} -> Claude keeps working instead
#
# Config: .claude/hooks/gaterail-checks.txt (one check per line, "<cwd><TAB>
# <command>", '#' comments, blank lines ignored). Missing/empty config means
# "no checks configured" — this script is a strict no-op in that case. It
# never fabricates a check the repository doesn't have one of; see
# .claude/references/discovering-project-checks.md for why that matters.
#
# What we don't read from stdin: Claude Code's Stop event JSON carries
# session_id/transcript_path/etc. We don't need any of it — the retry/loop
# guard below is keyed off this project's own git state, not the session,
# so the same guard logic works whether or not those fields are present.
# (Deliberate: parsing stdin JSON would need jq/python3, a dependency this
# project's installer doesn't otherwise require.)
set -uo pipefail
# NOT `set -e`: a failing configured check is expected, normal control flow
# here, not a script bug — we must keep running after it to report a
# "block" decision, not abort.

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
CONFIG="$PROJECT_DIR/.claude/hooks/gaterail-checks.txt"
STATE="$PROJECT_DIR/.claude/hooks/.gaterail-state"
MAX_RETRIES=3

# No config, or config has no active (non-comment, non-blank) lines: no-op.
if [ ! -f "$CONFIG" ] || ! grep -qE '^[^#[:space:]]' "$CONFIG" 2>/dev/null; then
  exit 0
fi

cd "$PROJECT_DIR" || exit 0

# Not a git repo (or git unavailable): can't fingerprint state, can't run
# checks meaningfully against "what changed" — fail open rather than block
# on a project this hook can't actually reason about.
if ! git rev-parse --git-dir >/dev/null 2>&1; then
  exit 0
fi

# Fingerprint = current HEAD + hash of the full working-tree diff (staged
# and unstaged) against it. Two different edits that happen to produce an
# identical diff are indistinguishable here — acceptable; the fingerprint
# only needs to answer "did anything change since the last check," not
# uniquely identify the change.
fingerprint() {
  { git rev-parse HEAD 2>/dev/null || echo "no-commits"; git diff HEAD 2>/dev/null; } \
    | { command -v shasum >/dev/null 2>&1 && shasum -a 256 || sha256sum; } \
    | awk '{print $1}'
}

current_fp="$(fingerprint)"

# State file format: three lines — last-good fingerprint, last-attempted
# fingerprint, retry count for that last-attempted fingerprint.
last_good_fp=""
last_attempt_fp=""
retry_count=0
if [ -f "$STATE" ]; then
  last_good_fp="$(sed -n '1p' "$STATE" 2>/dev/null || true)"
  last_attempt_fp="$(sed -n '2p' "$STATE" 2>/dev/null || true)"
  retry_count="$(sed -n '3p' "$STATE" 2>/dev/null || echo 0)"
  case "$retry_count" in (''|*[!0-9]*) retry_count=0 ;; esac
fi

write_state() {
  printf '%s\n%s\n%s\n' "$1" "$2" "$3" > "$STATE"
}

# Nothing changed since the last time checks passed: skip re-running them.
if [ -n "$last_good_fp" ] && [ "$current_fp" = "$last_good_fp" ]; then
  exit 0
fi

# Same (still-failing) diff as last attempt: bump the counter; a new diff
# resets it to 1 (reset to a fresh attempt).
if [ "$current_fp" = "$last_attempt_fp" ]; then
  retry_count=$((retry_count + 1))
else
  retry_count=1
fi

failure=""
while IFS=$'\t' read -r check_cwd check_cmd || [ -n "${check_cwd:-}" ]; do
  case "$check_cwd" in (''|'#'*) continue ;; esac
  [ -z "${check_cmd:-}" ] && continue

  output="$(cd "$PROJECT_DIR/$check_cwd" 2>&1 && eval "$check_cmd" 2>&1)"
  status=$?
  if [ "$status" -ne 0 ]; then
    first_lines="$(printf '%s\n' "$output" | head -5)"
    failure="$check_cwd: \`$check_cmd\` failed (exit $status). $first_lines"
    break
  fi
done < "$CONFIG"

if [ -z "$failure" ]; then
  write_state "$current_fp" "$current_fp" 0
  exit 0
fi

write_state "$last_good_fp" "$current_fp" "$retry_count"

if [ "$retry_count" -gt "$MAX_RETRIES" ]; then
  echo "gaterail: check still failing after $MAX_RETRIES attempts on this diff — letting the turn end. Re-run the failing command yourself; see $CONFIG." >&2
  exit 0
fi

# Escape for JSON: backslashes, double quotes, and literal newlines.
escaped="$(printf '%s' "$failure" | sed -e 's/\\/\\\\/g' -e 's/"/\\"/g' | tr '\n' ' ')"
printf '{"decision":"block","reason":"%s Fix and the hook re-verifies automatically."}\n' "$escaped"
exit 0
