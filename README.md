# agent-skills-pack

A small set of [Claude Code](https://claude.com/claude-code) skills for
day-to-day development work: writing a spec before coding, reviewing
game/simulation logic for state bugs, and setting up CI/CD quality gates.
Extracted from a real project (a browser strategy game) and generalized —
none of these reference that project anymore.

## Skills included

| Skill | Use when |
|---|---|
| [`spec-driven-development`](.claude/skills/spec-driven-development/SKILL.md) | Starting a new project/feature with vague or ambiguous requirements. Gates work through Specify → Plan → Tasks → Implement. |
| [`game-logic-review`](.claude/skills/game-logic-review/SKILL.md) | Reviewing a change to turn-based/simulation logic — economy, movement, combat, AI, save/load, state sync. |
| [`ci-cd-and-automation`](.claude/skills/ci-cd-and-automation/SKILL.md) | Setting up or changing a CI/CD pipeline — quality gates, GitHub Actions, deployment strategy, rollback. |

## Install

Claude Code loads skills from `.claude/skills/<name>/SKILL.md` in a project,
or from `~/.claude/skills/` for every project.

**Per-project:**
```bash
cp -r agent-skills-pack/.claude/skills/* your-project/.claude/skills/
```

**Global (all projects):**
```bash
cp -r agent-skills-pack/.claude/skills/* ~/.claude/skills/
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
