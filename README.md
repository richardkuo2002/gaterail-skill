# gaterail-skill

[English](README.md) | [繁體中文](README.zh-TW.md) | [日本語](README.ja.md) | [한국어](README.ko.md)

> A collection of workflow skills for [Claude Code](https://claude.com/claude-code) that keep an agent on rails: settle what to build before writing code, and don't call it done until it's actually checked.

[Installation](#installation) · [Example](#try-the-example) · [How it works](#how-it-works) · [Limitations](#limitations)

## Why

An agent can produce a code diff before anyone has agreed on the scope. It can also stop after editing files even though tests, lint, type checks, or the build haven't been run.

GateRail is seven skills that put two explicit checkpoints — gates — around that gap:

1. **Specification gate** — before implementation, settle scope, acceptance
   criteria, and task order.
2. **Delivery/verification gate** — before declaring the work done, apply the
   repository's own checks (tests, lint, build) and the shared
   [Definition of Done](.claude/references/definition-of-done.md).

These are **agent-facing workflow instructions written in Markdown**, loaded
by Claude Code. They tell the agent what to do and in what order. They do not
technically prevent a filesystem write, a `git merge`, or a CI bypass —
nothing here is a sandbox or a permission system. See [Limitations](#limitations).

## Skills included

| Skill | Role in the workflow |
|---|---|
| [`spec-driven-development`](.claude/skills/spec-driven-development/SKILL.md) | **Specification gate.** Starting a new project/feature with vague or ambiguous requirements. Gates work through Specify → Plan → Tasks → Implement. |
| [`planning-and-task-breakdown`](.claude/skills/planning-and-task-breakdown/SKILL.md) | **Specification gate.** You have a spec or clear requirements and need to break work into ordered, implementable tasks. |
| [`api-and-interface-design`](.claude/skills/api-and-interface-design/SKILL.md) | **Specification gate.** Designing APIs, module boundaries, or any public interface between components. |
| [`incremental-implementation`](.claude/skills/incremental-implementation/SKILL.md) | **Delivery/verification gate.** Implementing any change that touches more than one file — land it in small, reviewable steps, each cleared against the [Definition of Done](.claude/references/definition-of-done.md). |
| [`test-driven-development`](.claude/skills/test-driven-development/SKILL.md) | **Delivery/verification gate.** Implementing logic, fixing a bug, or changing behavior — write the test first to prove it. |
| [`ci-cd-and-automation`](.claude/skills/ci-cd-and-automation/SKILL.md) | **Delivery/verification gate.** Setting up or changing a CI/CD pipeline — quality gates, GitHub Actions, deployment strategy, rollback. |
| [`git-workflow-and-versioning`](.claude/skills/git-workflow-and-versioning/SKILL.md) | **Delivery/verification gate.** Making any code change — committing, branching, resolving conflicts, cutting a release, writing a changelog. |

Two shared references back the delivery gate across skills:
[`definition-of-done.md`](.claude/references/definition-of-done.md) (the
standing bar every task clears) and
[`testing-patterns.md`](.claude/references/testing-patterns.md) (default test
patterns the `test-driven-development` skill points to).

## How it works

```text
Request
  → specification gate      (spec-driven-development, planning-and-task-breakdown,
                              api-and-interface-design)
  → approved implementation plan
  → implementation           (incremental-implementation, test-driven-development)
  → delivery/verification gate (ci-cd-and-automation, git-workflow-and-versioning,
                                 Definition of Done)
  → verified result, or an explicitly reported remaining failure
```

Each skill is a `SKILL.md` file Claude Code reads and follows when its
"Use when" condition matches your request — there's no separate program
enforcing this sequence; the skills' instructions are what carry it out.

## Limitations

- **Not a sandbox, permission system, or branch-protection replacement.**
  Nothing here restricts what the agent can read, write, or run.
- **Does not guarantee generated code is correct.** It structures the agent's
  process (spec first, tests first, checks before "done"); it doesn't verify
  claims beyond running the commands the repository already defines.
- **Does not replace human review or repository-specific engineering rules.**
  These are general-purpose defaults meant to be adapted, not a substitute for
  your team's own standards or a required reviewer.
- The delivery gate is only as strong as the repository's own checks. A repo
  with no tests or no CI gets the same encouragement to add them, but nothing
  here fabricates a check that doesn't exist.

## Installation

Claude Code loads skills from `.claude/skills/<name>/SKILL.md` in a project,
or from `~/.claude/skills/` for every project — no restart needed once a
skill file is in place. You don't need all seven skills; pick what you'll
actually use.

**Requirements:** Bash (the installer uses array and parameter-expansion
features from Bash 3.2+, which is what ships by default on macOS and most
Linux distributions), `cp`, `git` for cloning.

### Recommended: clone, inspect, then run

```bash
git clone https://github.com/richardkuo2002/gaterail-skill.git
cd gaterail-skill
cat install.sh          # read what you're about to run
./install.sh
```

There are no tagged releases yet — until one exists, "inspect it" means
reading `install.sh` and the skill you're about to install (both are plain
text) before running it, or pinning your clone to a specific reviewed commit
SHA with `git checkout <sha>`.

The installer lists the seven skills, asks which to install (numbers,
comma-separated, or `all`), then asks whether to install into the current
project (`./.claude/skills`) or globally (`~/.claude/skills`). If a selected
skill needs the shared `references/` files
(`incremental-implementation`, `planning-and-task-breakdown`, and
`test-driven-development` do), it installs those too, alongside `skills/`,
at `.claude/references/`.

**No `curl | bash` one-liner is offered.** The installer reads interactively
from stdin (which skills, which destination); piping it from `curl` would
feed the installer script itself as its own input instead of your answers,
so it wouldn't work as a one-liner even as a convenience method. Clone and
run it locally instead.

### Local clone (same thing, if you already have one)

```bash
cd /path/to/gaterail-skill
./install.sh
```

### Manual: copy one skill without the installer

```bash
cp -r gaterail-skill/.claude/skills/spec-driven-development your-project/.claude/skills/
```

If the skill you copy links to `../../references/*.md` (check its `## See
Also` section), also copy `gaterail-skill/.claude/references/` next to
`skills/` in the destination, or those links will be dangling.

### What gets created, and where

| Target | Path | Scope |
|---|---|---|
| Project | `./.claude/skills/<name>/` | this project only |
| Global | `~/.claude/skills/<name>/` | every project you run Claude Code in |
| Shared references (either target) | `<target>/.claude/references/definition-of-done.md`, `.../testing-patterns.md` | only copied if a selected skill needs them |

### Re-running / idempotency

- Re-running `install.sh` and selecting a skill that's already installed at
  the destination **asks for confirmation before replacing it** — it never
  silently overwrites. Decline and that skill is left untouched; the rest of
  your selection still installs.
- The two shared reference files are copied by filename into
  `.claude/references/`, without touching any other file already in that
  directory.
- `./install.sh --dry-run` runs the same interactive selection, prints every
  planned source → destination copy (and whether each would be new or would
  ask to replace something), and makes no filesystem change.

### Uninstall

```bash
./install.sh --uninstall           # asks for confirmation before deleting
./install.sh --uninstall --dry-run # shows what would be deleted, changes nothing
```

This asks for the same project/global target as install, then removes only:

- the seven known GateRail skill directories, if present at that destination;
- the two exact managed reference files (`definition-of-done.md`,
  `testing-patterns.md`), if present.

It never deletes the enclosing `.claude/`, `skills/`, or `references/`
directories (even if they end up empty), and never touches any file it
didn't install — anything else you've placed under `.claude/skills/` or
`.claude/references/` is left alone.

## Try the example

[`examples/python-cli/`](examples/python-cli/) walks the two gates end to
end on a small, real change to a stdlib-only Python CLI: a request to add
`--json` output, an approved spec, the implementation, and a verification
report — with the actual commands to reproduce each step yourself. It
doesn't call an LLM; it's the artifacts the workflow produces, so you can
read the whole loop in a few minutes.

## License

MIT — see [LICENSE](LICENSE).
