# gaterail-skill

[English](README.md) | [繁體中文](README.zh-TW.md) | [日本語](README.ja.md) | [한국어](README.ko.md)

エージェントを軌道に乗せたまま進める [Claude Code](https://claude.com/claude-code)
向けの7つのskill。コードを書く前に仕様を固め、順序立てたタスクに分解し、
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
| [`git-workflow-and-versioning`](.claude/skills/git-workflow-and-versioning/SKILL.md) | あらゆるコード変更のとき——コミット、ブランチ作成、コンフリクト解消、リリースの切り出し、チェンジログ作成。 |

## インストール

Claude Codeはプロジェクト内の `.claude/skills/<name>/SKILL.md` からskillを
読み込む。`~/.claude/skills/` に置けば全プロジェクトで共有できる。7つ全部
入れる必要はない——実際に使うものだけ選べばいい。

**対話式インストール（どのskillを、どこに入れるか選べる）：**
```bash
git clone https://github.com/richardkuo2002/gaterail-skill.git
cd gaterail-skill
./install.sh
```
skillの一覧を表示し、どれを入れるか（番号をカンマ区切り、または `all`）を
聞いたあと、現在のプロジェクトに入れるかグローバル（`~/.claude/skills/`）
に入れるかを聞く。

**手動インストール（特定のskillだけコピーしたい場合）：**
```bash
cp -r gaterail-skill/.claude/skills/spec-driven-development your-project/.claude/skills/
```

Claude Codeは新しいskillを自動的に検知する。再起動は不要。

## ライセンス

MIT — [LICENSE](LICENSE) を参照。
