#!/usr/bin/env bash
# Installs the optional delivery-gate Stop hook into the current project.
#
# Separate from install.sh on purpose: this installs a Claude Code hook
# (re-runs a configured command before every turn ends), a materially
# different concern from copying SKILL.md files, and an even-more-optional
# layer on top of them — see README.md's "Delivery-gate Stop hook" section.
#
# Usage:
#   ./scripts/install-verify-hook.sh              install into ./.claude
#   ./scripts/install-verify-hook.sh --dry-run     print planned actions, change nothing
#   ./scripts/install-verify-hook.sh --uninstall   remove the hook script + example config
#   ./scripts/install-verify-hook.sh --uninstall --dry-run
#
# Project-only (no $HOME-wide option, unlike install.sh): the hook's config
# (gaterail-checks.txt) and state are inherently per-repository, so a
# global install wouldn't mean anything different from a project one.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SRC_HOOK="$ROOT/.claude/hooks/verify-before-stop.sh"
SRC_EXAMPLE="$ROOT/.claude/hooks/gaterail-checks.txt.example"

DRY_RUN=0
UNINSTALL=0
for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY_RUN=1 ;;
    --uninstall) UNINSTALL=1 ;;
    *)
      echo "Unknown option: $arg" >&2
      echo "Usage: $0 [--dry-run] [--uninstall]" >&2
      exit 1
      ;;
  esac
done

if [ ! -f "$SRC_HOOK" ]; then
  echo "Error: $SRC_HOOK not found — is this run from inside the gaterail-skill checkout?" >&2
  exit 1
fi

DEST_DIR="$(pwd)/.claude/hooks"
DEST_HOOK="$DEST_DIR/verify-before-stop.sh"
DEST_EXAMPLE="$DEST_DIR/gaterail-checks.txt.example"
DEST_CONFIG="$DEST_DIR/gaterail-checks.txt"
DEST_STATE="$DEST_DIR/.gaterail-state"
SETTINGS="$(pwd)/.claude/settings.json"

HOOK_SNIPPET='{
  "hooks": {
    "Stop": [
      {
        "hooks": [
          { "type": "command", "command": "${CLAUDE_PROJECT_DIR}/.claude/hooks/verify-before-stop.sh" }
        ]
      }
    ]
  }
}'

# ---- uninstall --------------------------------------------------------------
run_uninstall() {
  local to_delete=()
  [ -f "$DEST_HOOK" ] && to_delete+=("$DEST_HOOK")
  [ -f "$DEST_EXAMPLE" ] && to_delete+=("$DEST_EXAMPLE")
  [ -f "$DEST_STATE" ] && to_delete+=("$DEST_STATE")

  if [ "${#to_delete[@]}" -eq 0 ]; then
    echo "Nothing to uninstall at $DEST_DIR."
    exit 0
  fi

  echo
  echo "The following would be deleted:"
  for p in "${to_delete[@]}"; do echo "  $p"; done
  echo
  echo "Note: $DEST_CONFIG (your filled-in check commands, if present) is never"
  echo "touched by uninstall — delete it yourself if you want it gone too."
  echo "$SETTINGS is also never touched — remove the Stop hook entry from it"
  echo "by hand if you added one."

  if [ "$DRY_RUN" -eq 1 ]; then
    echo
    echo "[dry-run] no changes made."
    exit 0
  fi

  echo
  read -rp "Delete these ${#to_delete[@]} path(s)? [y/N]: " confirm
  if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
    echo "Uninstall cancelled. No changes made."
    exit 0
  fi

  for p in "${to_delete[@]}"; do
    rm -f -- "$p"
    echo "Deleted $p"
  done
}

# ---- install / dry-run ------------------------------------------------------
run_install() {
  if [ "$DRY_RUN" -eq 1 ]; then
    echo "[dry-run] $SRC_HOOK -> $DEST_HOOK"
    echo "[dry-run] $SRC_EXAMPLE -> $DEST_EXAMPLE"
    if [ -f "$SETTINGS" ]; then
      echo "[dry-run] $SETTINGS already exists — would print a snippet to add by hand, not edit it"
    else
      echo "[dry-run] $SETTINGS does not exist — would create it with the Stop hook entry"
    fi
    echo
    echo "[dry-run] no changes made."
    exit 0
  fi

  mkdir -p "$DEST_DIR"

  if [ -f "$DEST_HOOK" ]; then
    echo "WARNING: $DEST_HOOK already exists." >&2
    read -rp "Replace it? [y/N]: " ans
    if [[ "$ans" =~ ^[Yy]$ ]]; then
      cp "$SRC_HOOK" "$DEST_HOOK"
      chmod +x "$DEST_HOOK"
      echo "Replaced $DEST_HOOK"
    else
      echo "Left existing $DEST_HOOK untouched."
    fi
  else
    cp "$SRC_HOOK" "$DEST_HOOK"
    chmod +x "$DEST_HOOK"
    echo "Installed $DEST_HOOK"
  fi

  if [ -f "$DEST_EXAMPLE" ]; then
    echo "Left existing $DEST_EXAMPLE untouched."
  else
    cp "$SRC_EXAMPLE" "$DEST_EXAMPLE"
    echo "Installed $DEST_EXAMPLE"
  fi

  echo
  if [ -f "$SETTINGS" ]; then
    echo "$SETTINGS already exists — not touching it automatically."
    echo "Add this to its \"hooks\" section yourself:"
    echo
    echo "$HOOK_SNIPPET"
  else
    mkdir -p "$(dirname "$SETTINGS")"
    printf '%s\n' "$HOOK_SNIPPET" >"$SETTINGS"
    echo "Created $SETTINGS with the Stop hook entry."
  fi

  echo
  echo "Next step: fill in $DEST_CONFIG (copy it from gaterail-checks.txt.example"
  echo "and name this project's real check commands — see"
  echo ".claude/references/discovering-project-checks.md). The hook is a no-op"
  echo "until that file exists with at least one active line."
}

if [ "$UNINSTALL" -eq 1 ]; then
  run_uninstall
else
  run_install
fi
