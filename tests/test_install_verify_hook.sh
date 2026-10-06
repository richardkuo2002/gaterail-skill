#!/usr/bin/env bash
# Scripted tests for scripts/install-verify-hook.sh. Mirrors test_install.sh's
# scratch-dir pattern.
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
INSTALLER="$REPO/scripts/install-verify-hook.sh"

fail() { echo "FAIL: $1" >&2; exit 1; }
pass() { echo "ok: $1"; }

# Runs the installer in a fresh scratch dir, feeding $1 as stdin, with args
# $2+. Leaves the scratch dir at $SCRATCH, restores the original cwd.
in_scratch() {
  local stdin_text="$1"; shift
  SCRATCH="$(mktemp -d)"
  local orig_dir
  orig_dir="$(pwd)"
  cd "$SCRATCH"
  printf '%b' "$stdin_text" | bash "$INSTALLER" "$@" >"$SCRATCH/.output" 2>&1 || true
  cd "$orig_dir"
}

# ---- dry-run makes no filesystem changes -----------------------------------
test_dry_run_makes_no_changes() {
  in_scratch ""
  rm -rf "$SCRATCH"
  SCRATCH="$(mktemp -d)"
  local orig_dir
  orig_dir="$(pwd)"
  cd "$SCRATCH"
  bash "$INSTALLER" --dry-run >"$SCRATCH/.output" 2>&1 || true
  cd "$orig_dir"
  [ ! -e "$SCRATCH/.claude" ] || fail "dry-run created $SCRATCH/.claude"
  pass "dry-run makes no changes"
}

# ---- install creates the hook script, example config, and settings.json ---
test_install_creates_hook_example_and_settings() {
  in_scratch ""
  [ -x "$SCRATCH/.claude/hooks/verify-before-stop.sh" ] || fail "hook script not installed or not executable"
  [ -f "$SCRATCH/.claude/hooks/gaterail-checks.txt.example" ] || fail "example config not installed"
  [ -f "$SCRATCH/.claude/settings.json" ] || fail "settings.json not created"
  python3 -c "
import json
d = json.load(open('$SCRATCH/.claude/settings.json'))
assert d['hooks']['Stop'][0]['hooks'][0]['type'] == 'command'
assert 'verify-before-stop.sh' in d['hooks']['Stop'][0]['hooks'][0]['command']
" || fail "settings.json does not contain the expected Stop hook entry"
  pass "install creates the hook script, example config, and settings.json"
}

# ---- install.sh never writes a real gaterail-checks.txt --------------------
test_install_does_not_create_real_config() {
  in_scratch ""
  [ ! -e "$SCRATCH/.claude/hooks/gaterail-checks.txt" ] || fail "installer created a real (non-.example) config — it must never guess a check command"
  pass "install never creates a real gaterail-checks.txt (no guessed check commands)"
}

# ---- existing settings.json is never auto-edited ---------------------------
test_existing_settings_json_is_not_touched() {
  in_scratch ""
  local before='{"hooks":{"SomeOtherHook":[]}}'
  echo "$before" >"$SCRATCH/.claude/settings.json"

  local orig_dir
  orig_dir="$(pwd)"
  cd "$SCRATCH"
  printf 'n\n' | bash "$INSTALLER" >"$SCRATCH/.output2" 2>&1 || true
  cd "$orig_dir"

  local after
  after="$(cat "$SCRATCH/.claude/settings.json")"
  [ "$after" = "$before" ] || fail "installer modified an existing settings.json"
  grep -q '"hooks"' "$SCRATCH/.output2" || fail "installer did not print a hook snippet when settings.json already existed"
  pass "an existing settings.json is never auto-edited; a snippet is printed instead"
}

# ---- second install over an existing hook script asks, declining leaves it
# untouched --------------------------------------------------------------
test_second_install_decline_leaves_hook_untouched() {
  in_scratch ""
  local marker="$SCRATCH/.claude/hooks/verify-before-stop.sh"
  echo "# LOCAL EDIT MARKER" >>"$marker"
  local before
  before="$(cat "$marker")"

  local orig_dir
  orig_dir="$(pwd)"
  cd "$SCRATCH"
  printf 'n\n' | bash "$INSTALLER" >"$SCRATCH/.output3" 2>&1 || true
  cd "$orig_dir"

  local after
  after="$(cat "$marker")"
  [ "$before" = "$after" ] || fail "declining replacement modified $marker"
  pass "second install: decline leaves the existing hook script untouched"
}

# ---- uninstall removes the hook + example, never the real config or
# settings.json --------------------------------------------------------------
test_uninstall_leaves_real_config_and_settings_alone() {
  in_scratch ""
  echo "real check command" >"$SCRATCH/.claude/hooks/gaterail-checks.txt"
  local settings_before
  settings_before="$(cat "$SCRATCH/.claude/settings.json")"

  local orig_dir
  orig_dir="$(pwd)"
  cd "$SCRATCH"
  printf 'y\n' | bash "$INSTALLER" --uninstall >"$SCRATCH/.uninstall-output" 2>&1 || true
  cd "$orig_dir"

  [ ! -e "$SCRATCH/.claude/hooks/verify-before-stop.sh" ] || fail "uninstall left the hook script in place"
  [ ! -e "$SCRATCH/.claude/hooks/gaterail-checks.txt.example" ] || fail "uninstall left the example config in place"
  [ -f "$SCRATCH/.claude/hooks/gaterail-checks.txt" ] || fail "uninstall deleted the real (user-filled) config — it must not"
  local settings_after
  settings_after="$(cat "$SCRATCH/.claude/settings.json")"
  [ "$settings_before" = "$settings_after" ] || fail "uninstall modified settings.json"
  pass "uninstall removes the hook + example, leaves the real config and settings.json alone"
}

test_dry_run_makes_no_changes
test_install_creates_hook_example_and_settings
test_install_does_not_create_real_config
test_existing_settings_json_is_not_touched
test_second_install_decline_leaves_hook_untouched
test_uninstall_leaves_real_config_and_settings_alone

echo
echo "All install-verify-hook.sh scripted tests passed."
