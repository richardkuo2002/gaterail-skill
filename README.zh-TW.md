# gaterail-skill

[English](README.md) | [繁體中文](README.zh-TW.md) | [日本語](README.ja.md) | [한국어](README.ko.md)

六個 [Claude Code](https://claude.com/claude-code) skill，讓 agent 照著軌道走：
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

## 安裝

Claude Code 會從專案裡的 `.claude/skills/<name>/SKILL.md` 載入 skill，
也支援放在 `~/.claude/skills/` 給所有專案共用。

**單一專案：**
```bash
cp -r gaterail-skill/.claude/skills/* your-project/.claude/skills/
```

**全域（所有專案共用）：**
```bash
cp -r gaterail-skill/.claude/skills/* ~/.claude/skills/
```

Claude Code 會自動偵測新的 skill，不用重啟。

## 備註

`spec-driven-development` 還引用了 `context-engineering`，用來在實作階段載入
對的規格段落與原始檔案。這個 skill 沒收進來——因為在抽出這個 pack 的原始
專案裡它根本還不存在。其他 skill 沒有它也能正常運作。

這裡有幾個 skill 會指向這個 pack 目前還沒收錄的其他 skill
（`git-workflow-and-versioning`、`deprecation-and-migration`、
`browser-testing-with-devtools`）——這些只是選讀性質的延伸參考，不是必要條件。

## 授權

MIT — 詳見 [LICENSE](LICENSE)。
