#!/usr/bin/env bash
# Interactive installer: pick which skills to copy, and where.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILLS_DIR="$ROOT/.claude/skills"

names=()
for d in "$SKILLS_DIR"/*/; do
  names+=("$(basename "$d")")
done

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
  for idx in "${idxs[@]}"; do
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

echo
echo "Install to:"
echo "  1) this project (./.claude/skills)"
echo "  2) all your projects (~/.claude/skills)"
read -rp "Choice [1]: " target
target="${target:-1}"

if [ "$target" = "2" ]; then
  dest="$HOME/.claude/skills"
else
  dest="$(pwd)/.claude/skills"
fi

mkdir -p "$dest"
for n in "${selected[@]}"; do
  cp -r "$SKILLS_DIR/$n" "$dest/"
  echo "Installed $n -> $dest/$n"
done
