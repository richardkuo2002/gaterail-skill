## What changed

<!-- One or two sentences. -->

## Why

<!-- The gap or bug this addresses. -->

## Before / after (required if a skill's instructed behavior changed)

<!--
Only needed for a change to what a SKILL.md tells the agent to do — not for
typo fixes, formatting, or docs-only changes.

Before: <what the agent produced under the old wording>
After:  <what the agent produces under the new wording>
-->

## Checklist

- [ ] Scoped to one concern (see `CONTRIBUTING.md`)
- [ ] `bash -n install.sh` passes (if `install.sh` changed)
- [ ] Manually exercised `install.sh` in a scratch directory, not `~/.claude/skills` (if `install.sh` changed)
- [ ] `python -m unittest -v` passes from `examples/python-cli/` (if that example changed)
- [ ] Relevant README(s) updated to match actual behavior
- [ ] No new external runtime dependency introduced
