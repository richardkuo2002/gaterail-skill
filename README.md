# gaterail-skill

[English](README.md) | [繁體中文](README.zh-TW.md) | [日本語](README.ja.md) | [한국어](README.ko.md)

Seven [Claude Code](https://claude.com/claude-code) skills that keep an agent
on rails: spec the work before touching code, break it into ordered tasks,
implement it incrementally with tests, and gate every change behind CI
before it ships. Extracted from a real project and generalized — nothing
here is tied to that project anymore.

## Skills included

| Skill | Use when |
|---|---|
| [`spec-driven-development`](.claude/skills/spec-driven-development/SKILL.md) | Starting a new project/feature with vague or ambiguous requirements. Gates work through Specify → Plan → Tasks → Implement. |
| [`planning-and-task-breakdown`](.claude/skills/planning-and-task-breakdown/SKILL.md) | You have a spec or clear requirements and need to break work into ordered, implementable tasks. |
| [`api-and-interface-design`](.claude/skills/api-and-interface-design/SKILL.md) | Designing APIs, module boundaries, or any public interface between components. |
| [`incremental-implementation`](.claude/skills/incremental-implementation/SKILL.md) | Implementing any change that touches more than one file — land it in small, reviewable steps instead of one big drop. |
| [`test-driven-development`](.claude/skills/test-driven-development/SKILL.md) | Implementing logic, fixing a bug, or changing behavior — write the test first to prove it. |
| [`ci-cd-and-automation`](.claude/skills/ci-cd-and-automation/SKILL.md) | Setting up or changing a CI/CD pipeline — quality gates, GitHub Actions, deployment strategy, rollback. |
| [`git-workflow-and-versioning`](.claude/skills/git-workflow-and-versioning/SKILL.md) | Making any code change — committing, branching, resolving conflicts, cutting a release, writing a changelog. |

## Install

Claude Code loads skills from `.claude/skills/<name>/SKILL.md` in a project,
or from `~/.claude/skills/` for every project. You don't need all seven —
pick what you'll actually use.

**Interactive (pick which skills, and where):**
```bash
git clone https://github.com/richardkuo2002/gaterail-skill.git
cd gaterail-skill
./install.sh
```
It lists the skills, asks which ones (numbers, comma-separated, or `all`),
then asks whether to install into the current project or globally
(`~/.claude/skills/`).

**Manual, if you'd rather just copy a specific skill:**
```bash
cp -r gaterail-skill/.claude/skills/spec-driven-development your-project/.claude/skills/
```

Claude Code picks up new skills automatically — no restart needed.

## License

MIT — see [LICENSE](LICENSE).
