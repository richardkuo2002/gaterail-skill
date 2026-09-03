# gaterail-skill

[English](README.md) | [繁體中文](README.zh-TW.md) | [日本語](README.ja.md) | [한국어](README.ko.md)

에이전트가 궤도를 벗어나지 않게 잡아주는 [Claude Code](https://claude.com/claude-code)
skill 두 가지. 코드를 건드리기 전에 스펙을 먼저 쓰고, 배포 전에는 모든 변경사항이
CI를 통과하도록 게이트를 건다. 실제 프로젝트에서 추출해 범용화했으며, 원래
프로젝트에 대한 의존성은 남아 있지 않다.

## 포함된 skill

| Skill | 사용 시점 |
|---|---|
| [`spec-driven-development`](.claude/skills/spec-driven-development/SKILL.md) | 요구사항이 모호하거나 불명확한 상태로 새 프로젝트/기능을 시작할 때. Specify → Plan → Tasks → Implement 4단계로 게이트를 건다. |
| [`ci-cd-and-automation`](.claude/skills/ci-cd-and-automation/SKILL.md) | CI/CD 파이프라인을 구축하거나 수정할 때 — 품질 게이트, GitHub Actions, 배포 전략, 롤백. |

## 설치

Claude Code는 프로젝트 안의 `.claude/skills/<name>/SKILL.md`에서 skill을
불러온다. `~/.claude/skills/`에 두면 모든 프로젝트에서 공유된다.

**프로젝트별:**
```bash
cp -r gaterail-skill/.claude/skills/* your-project/.claude/skills/
```

**전역(모든 프로젝트 공유):**
```bash
cp -r gaterail-skill/.claude/skills/* ~/.claude/skills/
```

Claude Code가 새 skill을 자동으로 인식한다. 재시작 불필요.

## 참고

`spec-driven-development`는 특정 단계의 세부 내용을 보완하기 위해 몇 가지
관련 skill(`incremental-implementation`, `test-driven-development`,
`planning-and-task-breakdown`, `context-engineering`,
`api-and-interface-design`)을 참조한다. 이것들 없이도 단독으로 동작하며,
추후 이 pack에 추가될 후보들이다.

## 라이선스

MIT — [LICENSE](LICENSE) 참고.
