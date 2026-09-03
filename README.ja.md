# gaterail-skill

[English](README.md) | [繁體中文](README.zh-TW.md) | [日本語](README.ja.md) | [한국어](README.ko.md)

エージェントを軌道に乗せたまま進める [Claude Code](https://claude.com/claude-code)
向けの6つのskill。コードを書く前に仕様を固め、順序立てたタスクに分解し、
テストを書きながら少しずつ実装し、変更を出荷する前には必ずCIを通す。実際の
プロジェクトから切り出して汎用化したもので、元のプロジェクトへの依存はもう
残っていない。

## 収録skill

| Skill | 使うタイミング |
|---|---|
| [`spec-driven-development`](.claude/skills/spec-driven-development/SKILL.md) | 要件が曖昧なまま新しいプロジェクトや機能に着手するとき。Specify → Plan → Tasks → Implement の4段階でゲートする。 |
| [`planning-and-task-breakdown`](.claude/skills/planning-and-task-breakdown/SKILL.md) | 仕様や明確な要件があり、順序立った実装可能なタスクに分解したいとき。 |
| [`api-and-interface-design`](.claude/skills/api-and-interface-design/SKILL.md) | API、モジュール境界、コンポーネント間の公開インターフェースを設計するとき。 |
| [`incremental-implementation`](.claude/skills/incremental-implementation/SKILL.md) | 複数ファイルにまたがる変更を実装するとき——一度に大きく出すのではなく、小さくレビュー可能な単位で進める。 |
| [`test-driven-development`](.claude/skills/test-driven-development/SKILL.md) | ロジックの実装、バグ修正、挙動の変更をするとき——まずテストを書いて動くことを証明する。 |
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

`spec-driven-development` はさらに `context-engineering` を参照し、実装時に
仕様の適切な部分とソースファイルを読み込む用途で使う。このskillはこのパック
には含まれていない——切り出し元のプロジェクトにまだ存在しないため。他の
skillはこれがなくても問題なく動作する。

ここに含まれるいくつかのskillは、まだこのパックに収録していない他のskill
（`git-workflow-and-versioning`、`deprecation-and-migration`、
`browser-testing-with-devtools`）を参照している——これらは任意の深掘り用
参照であり、必須ではない。

## ライセンス

MIT — [LICENSE](LICENSE) を参照。
