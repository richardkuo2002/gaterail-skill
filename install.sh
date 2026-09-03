#!/usr/bin/env bash
# Interactive installer: pick which skills to copy, and where.
#
# Usage:
#   ./install.sh                    interactive install
#   ./install.sh --dry-run          run the same selection flow, print the
#                                    planned operations, change nothing
#   ./install.sh --uninstall        remove previously installed GateRail
#                                    skills/references (asks for confirmation)
#   ./install.sh --uninstall --dry-run
#                                    show what --uninstall would remove,
#                                    change nothing, skip the confirmation
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILLS_DIR="$ROOT/.claude/skills"
REFS_SRC_DIR="$ROOT/.claude/references"
MANAGED_REF_FILES=("definition-of-done.md" "testing-patterns.md")

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

if [ ! -d "$SKILLS_DIR" ]; then
  echo "Error: $SKILLS_DIR not found — is this run from inside the gaterail-skill checkout?" >&2
  exit 1
fi

names=()
for d in "$SKILLS_DIR"/*/; do
  names+=("$(basename "$d")")
done

if [ "${#names[@]}" -eq 0 ]; then
  echo "Error: no skills found under $SKILLS_DIR" >&2
  exit 1
fi

# ---- shared: ask which of $HOME or the current project to target ----------
ask_destination() {
  echo
  echo "Target:"
  echo "  1) this project (./.claude/skills)"
  echo "  2) all your projects (~/.claude/skills)"
  read -rp "Choice [1]: " target
  target="${target:-1}"
  if [ "$target" = "2" ]; then
    dest="$HOME/.claude/skills"
  else
    dest="$(pwd)/.claude/skills"
  fi
}

# ---- uninstall --------------------------------------------------------------
run_uninstall() {
  ask_destination
  local refs_dir
  refs_dir="$(dirname "$dest")/references"

  local to_delete=()
  for n in "${names[@]}"; do
    local p="$dest/$n"
    [ -d "$p" ] && to_delete+=("$p")
  done
  for f in "${MANAGED_REF_FILES[@]}"; do
    local p="$refs_dir/$f"
    [ -f "$p" ] && to_delete+=("$p")
  done

  if [ "${#to_delete[@]}" -eq 0 ]; then
    echo "Nothing to uninstall at $dest (or $refs_dir)."
    exit 0
  fi

  echo
  echo "The following GateRail-managed paths would be deleted:"
  for p in "${to_delete[@]}"; do
    echo "  $p"
  done

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

  local deleted=() skipped=()
  for p in "${to_delete[@]}"; do
    if [ -d "$p" ]; then
      rm -rf -- "$p"
      deleted+=("$p")
    elif [ -f "$p" ]; then
      rm -f -- "$p"
      deleted+=("$p")
    else
      skipped+=("$p")
    fi
  done

  echo
  echo "Summary:"
  echo "  Deleted (${#deleted[@]}):"
  for p in "${deleted[@]+"${deleted[@]}"}"; do echo "    $p"; done
  if [ "${#skipped[@]}" -gt 0 ]; then
    echo "  Skipped, already gone (${#skipped[@]}):"
    for p in "${skipped[@]}"; do echo "    $p"; done
  fi
  echo
  echo "Note: enclosing directories (.claude/, skills/, references/) are left in place"
  echo "even if now empty, and no file outside the paths above was touched."
}

# ---- install / dry-run ------------------------------------------------------
run_install() {
  echo "Available skills:"
  for i in "${!names[@]}"; do
    printf "  %d) %s\n" "$((i + 1))" "${names[$i]}"
  done
  echo

  read -rp "Install which? (numbers comma-separated, or 'all'): " choice
  choice="${choice// /}"

  selected=()
  if [ "$choice" = "all" ]; then
    selected=("${names[@]}")
  else
    IFS=',' read -ra idxs <<< "$choice"
    for idx in "${idxs[@]+"${idxs[@]}"}"; do
      if ! [[ "$idx" =~ ^[0-9]+$ ]] || [ "$idx" -lt 1 ] || [ "$idx" -gt "${#names[@]}" ]; then
        echo "Skipping invalid choice: $idx" >&2
        continue
      fi
      selected+=("${names[$((idx - 1))]}")
    done
  fi

  if [ "${#selected[@]}" -eq 0 ]; then
    echo "Nothing selected, nothing installed."
    exit 0
  fi

  ask_destination

  # A skill needs the shared references/ dir iff its SKILL.md links to it.
  local needs_refs=0
  for n in "${selected[@]}"; do
    if grep -q '\.\./\.\./references/' "$SKILLS_DIR/$n/SKILL.md" 2>/dev/null; then
      needs_refs=1
    fi
  done

  local installed=() replaced=() untouched=()

  if [ "$DRY_RUN" -eq 1 ]; then
    echo
    echo "[dry-run] destination: $dest"
    for n in "${selected[@]}"; do
      local src="$SKILLS_DIR/$n" dst="$dest/$n"
      if [ -d "$dst" ]; then
        echo "[dry-run] $src -> $dst  (already exists — would ask before replacing)"
      else
        echo "[dry-run] $src -> $dst  (new)"
      fi
    done
    if [ "$needs_refs" -eq 1 ]; then
      local refs_dst
      refs_dst="$(dirname "$dest")/references"
      for f in "${MANAGED_REF_FILES[@]}"; do
        echo "[dry-run] $REFS_SRC_DIR/$f -> $refs_dst/$f"
      done
    fi
    echo
    echo "[dry-run] no changes made."
    exit 0
  fi

  mkdir -p "$dest"
  for n in "${selected[@]}"; do
    local src="$SKILLS_DIR/$n" dst="$dest/$n"
    if [ -d "$dst" ]; then
      echo "WARNING: $dst already exists." >&2
      read -rp "Replace $n at $dst? [y/N]: " ans
      if [[ "$ans" =~ ^[Yy]$ ]]; then
        rm -rf -- "$dst"
        cp -r "$src" "$dst"
        echo "Replaced $n -> $dst"
        replaced+=("$dst")
      else
        echo "Left existing $dst untouched."
        untouched+=("$dst")
      fi
    else
      cp -r "$src" "$dst"
      echo "Installed $n -> $dst"
      installed+=("$dst")
    fi
  done

  local refs_status="not needed"
  if [ "$needs_refs" -eq 1 ]; then
    local refs_dst
    refs_dst="$(dirname "$dest")/references"
    mkdir -p "$refs_dst"
    for f in "${MANAGED_REF_FILES[@]}"; do
      cp "$REFS_SRC_DIR/$f" "$refs_dst/$f"
      echo "Installed reference -> $refs_dst/$f"
    done
    refs_status="$refs_dst"
  fi

  echo
  echo "Summary:"
  echo "  Installed (${#installed[@]}):"
  for p in "${installed[@]+"${installed[@]}"}"; do echo "    $p"; done
  echo "  Replaced (${#replaced[@]}):"
  for p in "${replaced[@]+"${replaced[@]}"}"; do echo "    $p"; done
  echo "  Left untouched, replacement declined (${#untouched[@]}):"
  for p in "${untouched[@]+"${untouched[@]}"}"; do echo "    $p"; done
  echo "  Shared references: $refs_status"
}

if [ "$UNINSTALL" -eq 1 ]; then
  run_uninstall
else
  run_install
fi
