# Contributing

## Reporting a bug

Open an issue with the [bug report template](.github/ISSUE_TEMPLATE/bug_report.yml).
A good bug report for this repo usually includes:

- Which skill or which part of `install.sh` is involved.
- What you expected the agent (or the installer) to do, and what it did
  instead.
- The exact command or prompt that triggered it, and the Claude Code /
  Bash version if relevant.

If you've found a security issue (e.g. the installer could be tricked into
writing outside its intended destination), see [SECURITY.md](SECURITY.md)
instead of filing a public issue.

## Proposing a workflow integration

If you want to adapt one of these skills to a different stack, CI provider,
or team convention, open an issue first describing the gap — most of these
skills are meant to be generic, so a concrete mismatch (a step that doesn't
apply, a check that's missing) is more useful than "make it more flexible."

## Updating docs

- Keep English (`README.md`) as the source of truth.
- `README.zh-TW.md`, `README.ja.md`, `README.ko.md` should stay accurate,
  not necessarily word-for-word — update the specific lines that became
  wrong, rather than re-translating the whole file, unless you're doing a
  full pass on that translation.
- If you change what `install.sh` actually does, update every README that
  documents installation in the same change.

## Testing installer changes

`tests/test_install.sh` feeds fixed stdin into `install.sh` inside a scratch
directory (never your real `~/.claude/skills`) and asserts on the resulting
filesystem tree; CI runs it on every push, alongside `bash -n install.sh`
for syntax. Run it locally before proposing a change:

```bash
bash tests/test_install.sh
```

It covers, at minimum:

- A second install over an already-installed skill asks before replacing,
  and declining leaves it untouched.
- An existing, unrelated file in the destination `references/` directory
  survives an install or uninstall.
- `--uninstall` never deletes `.claude/`, `skills/`, or `references/`
  themselves, even when they end up empty.
- `--dry-run` makes no filesystem changes.

If your change adds new interactive prompts or destination paths, add a
case to `tests/test_install.sh` alongside it rather than falling back to
manual-only verification.

## Contribution checklist

- [ ] Change is scoped to one concern (one skill, one docs fix, one
      installer behavior) — not bundled with unrelated cleanup.
- [ ] If a skill's *behavior* changed (not just wording), the PR description
      includes a before/after example of what the agent would do differently.
- [ ] If `install.sh` changed, `bash tests/test_install.sh` passes and the
      relevant README(s) still describe its actual behavior.
- [ ] `bash -n install.sh` passes.
- [ ] If `examples/python-cli/` changed, `python -m unittest -v` passes from
      that directory.
- [ ] No new external runtime dependency was introduced.

## Skill behavior changes need before/after examples

A PR that changes what a skill instructs the agent to do (not just typo or
formatting fixes) should show, concretely: what a prompt matching that
skill's "Use when" condition produced before the change, and what it
produces after. This is the same bar the `test-driven-development` skill
asks of a bug fix — show the failure, then show it fixed.
