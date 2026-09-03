# gaterail-skill

[English](README.md) | [繁體中文](README.zh-TW.md) | [日本語](README.ja.md) | [한국어](README.ko.md)

エージェントを軌道に乗せたまま進める [Claude Code](https://claude.com/claude-code)
向けの2つのskill。コードを書く前に仕様を固め、変更を出荷する前には必ずCIを
通す。実際のプロジェクトから切り出して汎用化したもので、元のプロジェクトへの
依存はもう残っていない。

## 収録skill

| Skill | 使うタイミング |
|---|---|
| [`spec-driven-development`](.claude/skills/spec-driven-development/SKILL.md) | 要件が曖昧なまま新しいプロジェクトや機能に着手するとき。Specify → Plan → Tasks → Implement の4段階でゲートする。 |
| [`ci-cd-and-automation`](.claude/skills/ci-cd-and-automation/SKILL.md) | CI/CDパイプラインを構築・変更するとき——品質ゲート、GitHub Actions、デプロイ戦略、ロールバック。 |

## インストール

Claude Codeはプロジェクト内の `.claude/skills/<name>/SKILL.md` からskillを
読み込む。`~/.claude/skills/` に置けば全プロジェクトで共有できる。

**プロジェクト単位：**
```bash
cp -r gaterail-skill/.claude/skills/* your-project/.claude/skills/
```

**全プロジェクト共通：**
```bash
cp -r gaterail-skill/.claude/skills/* ~/.claude/skills/
```

Claude Codeは新しいskillを自動的に検知する。再起動は不要。

## 補足

`spec-driven-development` は特定フェーズの詳細を補うため、いくつかの
関連skill（`incremental-implementation`、`test-driven-development`、
`planning-and-task-breakdown`、`context-engineering`、
`api-and-interface-design`）を参照する。これらがなくても単体で機能する。
今後このパックに追加する候補。

## ライセンス

MIT — [LICENSE](LICENSE) を参照。
