# gaterail-skill

Two [Claude Code](https://claude.com/claude-code) skills that keep an agent
on rails: spec the work before touching code, then gate every change behind
CI before it ships. Extracted from a real project and generalized — nothing
here is tied to that project anymore.

## Skills included

| Skill | Use when |
|---|---|
| [`spec-driven-development`](.claude/skills/spec-driven-development/SKILL.md) | Starting a new project/feature with vague or ambiguous requirements. Gates work through Specify → Plan → Tasks → Implement. |
| [`ci-cd-and-automation`](.claude/skills/ci-cd-and-automation/SKILL.md) | Setting up or changing a CI/CD pipeline — quality gates, GitHub Actions, deployment strategy, rollback. |

## Install

Claude Code loads skills from `.claude/skills/<name>/SKILL.md` in a project,
or from `~/.claude/skills/` for every project.

**Per-project:**
```bash
cp -r gaterail-skill/.claude/skills/* your-project/.claude/skills/
```

**Global (all projects):**
```bash
cp -r gaterail-skill/.claude/skills/* ~/.claude/skills/
```

Claude Code picks up new skills automatically — no restart needed.

## Notes

`spec-driven-development` references a few sibling skills
(`incremental-implementation`, `test-driven-development`,
`planning-and-task-breakdown`, `context-engineering`, `api-and-interface-design`)
for deeper detail on specific phases. It works standalone without them; those
are candidates for a future addition to this pack.

## License

MIT — see [LICENSE](LICENSE).
