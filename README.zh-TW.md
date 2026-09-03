# gaterail-skill

[English](README.md) | [繁體中文](README.zh-TW.md) | [日本語](README.ja.md) | [한국어](README.ko.md)

七個 [Claude Code](https://claude.com/claude-code) skill，讓 agent 照著軌道走：
動手寫程式前先寫規格、拆成有順序的任務、用測試驅動、一小步一小步實作，每個
改動上線前都要先過 CI 這一關。從實際專案抽出來後已經通用化——內容不再綁死
原本的專案。

## 包含的 skill

| Skill | 什麼時候用 |
|---|---|
| [`spec-driven-development`](.claude/skills/spec-driven-development/SKILL.md) | 開始一個新專案/功能，需求還模糊或不明確時。透過 Specify → Plan → Tasks → Implement 四階段把關。 |
| [`planning-and-task-breakdown`](.claude/skills/planning-and-task-breakdown/SKILL.md) | 已經有規格或明確需求，需要拆成有順序、可執行的任務時。 |
| [`api-and-interface-design`](.claude/skills/api-and-interface-design/SKILL.md) | 設計 API、模組邊界，或任何元件之間的公開介面時。 |
| [`incremental-implementation`](.claude/skills/incremental-implementation/SKILL.md) | 實作會動到一個以上檔案的改動——拆成小步驟、每步都可審查，而不是一次丟出一大包。 |
| [`test-driven-development`](.claude/skills/test-driven-development/SKILL.md) | 實作邏輯、修 bug、改變行為時——先寫測試證明它動。 |
| [`ci-cd-and-automation`](.claude/skills/ci-cd-and-automation/SKILL.md) | 建立或修改 CI/CD 流程——品質關卡、GitHub Actions、部署策略、回滾機制。 |
| [`git-workflow-and-versioning`](.claude/skills/git-workflow-and-versioning/SKILL.md) | 任何程式改動——commit、開分支、解衝突、發版本、寫 changelog。 |

## 安裝

Claude Code 會從專案裡的 `.claude/skills/<name>/SKILL.md` 載入 skill，
也支援放在 `~/.claude/skills/` 給所有專案共用。不用七個全裝——挑你真的會
用到的就好。

**互動式安裝（選要哪些 skill、裝到哪）：**
```bash
git clone https://github.com/richardkuo2002/gaterail-skill.git
cd gaterail-skill
./install.sh
```
它會列出所有 skill，問你要哪幾個（用數字、逗號分隔，或輸入 `all`），
再問要裝到目前專案還是全域（`~/.claude/skills/`）。如果你選的 skill 需要
共用的 `references/` 檔案（`incremental-implementation`、
`planning-and-task-breakdown`、`test-driven-development` 需要），安裝程式
也會一併裝到 `.claude/references/`。

再次執行安裝程式、選到已經裝過的 skill 時，會先警告並要求確認才會覆蓋，
不會偷偷蓋掉。也支援：
```bash
./install.sh --dry-run      # 走一樣的互動流程，只印出會做什麼，不改任何檔案
./install.sh --uninstall    # 移除已安裝的 GateRail skill 與共用 references
```

**手動安裝（只想複製某一個 skill）：**
```bash
cp -r gaterail-skill/.claude/skills/spec-driven-development your-project/.claude/skills/
```
如果那個 skill 的 `## See Also` 有連到 `../../references/*.md`，記得把
`gaterail-skill/.claude/references/` 也複製到目的地的 `.claude/references/`，
不然連結會失效。

Claude Code 會自動偵測新的 skill，不用重啟。

## 授權

MIT — 詳見 [LICENSE](LICENSE)。
