# gaterail-skill

[English](README.md) | [繁體中文](README.zh-TW.md) | [日本語](README.ja.md) | [한국어](README.ko.md)

에이전트가 궤도를 벗어나지 않게 잡아주는 [Claude Code](https://claude.com/claude-code)
skill 일곱 가지. 코드를 건드리기 전에 스펙을 먼저 쓰고, 순서대로 정리된
작업으로 나누고, 테스트를 먼저 쓰며 조금씩 구현하고, 배포 전에는 모든
변경사항이 CI를 통과하도록 게이트를 건다. 실제 프로젝트에서 추출해
범용화했으며, 원래 프로젝트에 대한 의존성은 남아 있지 않다.

## 포함된 skill

| Skill | 사용 시점 |
|---|---|
| [`spec-driven-development`](.claude/skills/spec-driven-development/SKILL.md) | 요구사항이 모호하거나 불명확한 상태로 새 프로젝트/기능을 시작할 때. Specify → Plan → Tasks → Implement 4단계로 게이트를 건다. |
| [`planning-and-task-breakdown`](.claude/skills/planning-and-task-breakdown/SKILL.md) | 스펙이나 명확한 요구사항이 있고, 이를 순서대로 정리된 실행 가능한 작업으로 나눠야 할 때. |
| [`api-and-interface-design`](.claude/skills/api-and-interface-design/SKILL.md) | API, 모듈 경계, 컴포넌트 간 공개 인터페이스를 설계할 때. |
| [`incremental-implementation`](.claude/skills/incremental-implementation/SKILL.md) | 두 개 이상 파일을 건드리는 변경을 구현할 때 — 한 번에 크게 던지지 않고 작고 검토 가능한 단계로 나눈다. |
| [`test-driven-development`](.claude/skills/test-driven-development/SKILL.md) | 로직을 구현하거나 버그를 고치거나 동작을 바꿀 때 — 먼저 테스트를 써서 동작을 증명한다. |
| [`ci-cd-and-automation`](.claude/skills/ci-cd-and-automation/SKILL.md) | CI/CD 파이프라인을 구축하거나 수정할 때 — 품질 게이트, GitHub Actions, 배포 전략, 롤백. |
| [`git-workflow-and-versioning`](.claude/skills/git-workflow-and-versioning/SKILL.md) | 어떤 코드 변경이든 — 커밋, 브랜치 작업, 충돌 해결, 릴리스 컷, 체인지로그 작성. |

## 설치

Claude Code는 프로젝트 안의 `.claude/skills/<name>/SKILL.md`에서 skill을
불러온다. `~/.claude/skills/`에 두면 모든 프로젝트에서 공유된다. 7개를 다
설치할 필요는 없다 — 실제로 쓸 것만 고르면 된다.

**대화형 설치(어떤 skill을, 어디에 설치할지 직접 선택):**
```bash
git clone https://github.com/richardkuo2002/gaterail-skill.git
cd gaterail-skill
./install.sh
```
설치 가능한 skill 목록을 보여주고 어떤 걸 설치할지(번호를 쉼표로 구분,
또는 `all`) 물어본 다음, 현재 프로젝트에 설치할지 전역
(`~/.claude/skills/`)에 설치할지 물어본다.

**수동 설치(특정 skill 하나만 복사하고 싶을 때):**
```bash
cp -r gaterail-skill/.claude/skills/spec-driven-development your-project/.claude/skills/
```

Claude Code가 새 skill을 자동으로 인식한다. 재시작 불필요.

## 라이선스

MIT — [LICENSE](LICENSE) 참고.
