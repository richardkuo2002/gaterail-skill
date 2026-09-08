#!/usr/bin/env bash
# Scripted tests for install.sh: feeds fixed stdin, asserts on the resulting
# filesystem tree in a scratch directory. Replaces the manual checklist in
# CONTRIBUTING.md's "Testing installer changes" section with something CI
# runs on every push instead of relying on a human running it by hand.
#
# Only exercises the "this project" destination (option 1, $(pwd)/.claude) —
# never option 2 ($HOME/.claude/skills), so this never touches a real home
# directory.
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
INSTALL="$REPO/install.sh"
SKILL_COUNT=$(find "$REPO/.claude/skills" -mindepth 1 -maxdepth 1 -type d | wc -l | tr -d ' ')

fail() { echo "FAIL: $1" >&2; exit 1; }
pass() { echo "ok: $1"; }

# Runs install.sh in a fresh scratch dir, feeding $1 as stdin, with args $2+.
# Leaves the scratch dir at $SCRATCH for the caller to inspect, and restores
# the original cwd on return.
in_scratch() {
  local stdin_text="$1"; shift
  SCRATCH="$(mktemp -d)"
  local orig_dir
  orig_dir="$(pwd)"
  cd "$SCRATCH"
  # %b (not %s): stdin_text is a plain double-quoted argument, so its \n is a
  # literal backslash-n, not a real newline — %b is what turns it into one.
  printf '%b' "$stdin_text" | bash "$INSTALL" "$@" >"$SCRATCH/.install-output" 2>&1 || true
  cd "$orig_dir"
}

# ---- dry-run makes no filesystem changes -----------------------------------
test_dry_run_makes_no_changes() {
  in_scratch "all\n1\n" --dry-run
  [ ! -e "$SCRATCH/.claude" ] || fail "dry-run created $SCRATCH/.claude"
  pass "dry-run makes no changes"
}

# ---- install creates every selected skill + shared references -------------
test_install_creates_skills_and_refs() {
  in_scratch "all\n1\n"
  local n
  n=$(find "$SCRATCH/.claude/skills" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | wc -l | tr -d ' ')
  [ "$n" = "$SKILL_COUNT" ] || fail "expected $SKILL_COUNT installed skills, got $n"
  [ -f "$SCRATCH/.claude/references/definition-of-done.md" ] || fail "definition-of-done.md not installed"
  [ -f "$SCRATCH/.claude/references/testing-patterns.md" ] || fail "testing-patterns.md not installed"
  pass "install creates all selected skills + shared references"
}

# ---- CONTRIBUTING.md check: second install over an existing skill asks,
# and declining leaves it untouched -----------------------------------------
test_second_install_decline_leaves_untouched() {
  in_scratch "all\n1\n"
  local marker="$SCRATCH/.claude/skills/spec-driven-development/SKILL.md"
  [ -f "$marker" ] || fail "setup: spec-driven-development not installed"
  echo "LOCAL EDIT MARKER" >>"$marker"
  local before
  before="$(cat "$marker")"

  local declines
  declines="$(printf 'n\n%.0s' $(seq 1 "$SKILL_COUNT"))"
  local orig_dir
  orig_dir="$(pwd)"
  cd "$SCRATCH"
  printf 'all\n1\n%s' "$declines" | bash "$INSTALL" >"$SCRATCH/.install-output-2" 2>&1 || true
  cd "$orig_dir"

  local after
  after="$(cat "$marker")"
  [ "$before" = "$after" ] || fail "declining replacement modified $marker"
  pass "second install: decline leaves existing skill untouched"
}

# ---- CONTRIBUTING.md check: an unrelated file in references/ survives -----
test_unrelated_reference_file_survives_install_and_uninstall() {
  in_scratch "all\n1\n"
  local refs_dir="$SCRATCH/.claude/references"
  echo "not managed by gaterail" >"$refs_dir/my-own-notes.md"

  # re-install over itself, accepting replacement, to exercise the refs copy path again
  local accepts
  accepts="$(printf 'y\n%.0s' $(seq 1 "$SKILL_COUNT"))"
  local orig_dir
  orig_dir="$(pwd)"
  cd "$SCRATCH"
  printf 'all\n1\n%s' "$accepts" | bash "$INSTALL" >"$SCRATCH/.install-output-3" 2>&1 || true
  cd "$orig_dir"
  [ -f "$refs_dir/my-own-notes.md" ] || fail "unrelated reference file did not survive re-install"

  cd "$SCRATCH"
  printf '1\ny\n' | bash "$INSTALL" --uninstall >"$SCRATCH/.uninstall-output" 2>&1 || true
  cd "$orig_dir"
  [ -f "$refs_dir/my-own-notes.md" ] || fail "unrelated reference file did not survive uninstall"
  pass "unrelated file in references/ survives install and uninstall"
}

# ---- CONTRIBUTING.md check: --uninstall never deletes the enclosing dirs --
test_uninstall_leaves_enclosing_dirs_even_when_empty() {
  in_scratch "all\n1\n"
  local orig_dir
  orig_dir="$(pwd)"
  cd "$SCRATCH"
  printf '1\ny\n' | bash "$INSTALL" --uninstall >"$SCRATCH/.uninstall-output-2" 2>&1 || true
  cd "$orig_dir"

  local n
  n=$(find "$SCRATCH/.claude/skills" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | wc -l | tr -d ' ')
  [ "$n" = "0" ] || fail "expected uninstall to remove all skill dirs, $n remain"
  [ -d "$SCRATCH/.claude/skills" ] || fail "uninstall deleted .claude/skills/ itself"
  [ -d "$SCRATCH/.claude/references" ] || fail "uninstall deleted .claude/references/ itself"
  [ -d "$SCRATCH/.claude" ] || fail "uninstall deleted .claude/ itself"
  pass "uninstall empties skill/reference dirs but leaves .claude/skills/ and .claude/references/ in place"
}

test_dry_run_makes_no_changes
test_install_creates_skills_and_refs
test_second_install_decline_leaves_untouched
test_unrelated_reference_file_survives_install_and_uninstall
test_uninstall_leaves_enclosing_dirs_even_when_empty

echo
echo "All install.sh scripted tests passed."
