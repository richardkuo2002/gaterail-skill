# gaterail-skill

[English](README.md) | [繁體中文](README.zh-TW.md) | [日本語](README.ja.md) | [한국어](README.ko.md)

兩個 [Claude Code](https://claude.com/claude-code) skill，讓 agent 照著軌道走：
動手寫程式前先寫規格，每個改動上線前都要先過 CI 這一關。從實際專案抽出來後
已經通用化——內容不再綁死原本的專案。

## 包含的 skill

| Skill | 什麼時候用 |
|---|---|
| [`spec-driven-development`](.claude/skills/spec-driven-development/SKILL.md) | 開始一個新專案/功能，需求還模糊或不明確時。透過 Specify → Plan → Tasks → Implement 四階段把關。 |
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

`spec-driven-development` 會引用幾個相關 skill
（`incremental-implementation`、`test-driven-development`、
`planning-and-task-breakdown`、`context-engineering`、`api-and-interface-design`）
來補充特定階段的細節。沒有這些也能獨立運作；未來可能會補進這個 pack。

## 授權

MIT — 詳見 [LICENSE](LICENSE)。
