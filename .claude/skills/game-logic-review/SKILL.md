---
name: game-logic-review
description: Use when reviewing a pull request or code change affecting game rules, turns, economy, movement, combat, AI factions, save data, or state synchronization.
---

# Game Logic Review Skill

## Review priorities
1. State corruption or invalid transitions
2. Resource duplication or negative values
3. Turn-order bugs
4. Save/load compatibility
5. Race conditions or duplicate command execution
6. UI displaying stale game state
7. AI exploiting rules unavailable to the player
8. Missing tests for boundary conditions

## Required review output
For each issue include:
- Severity: blocker, high, medium, low
- Exact file and relevant logic
- Reproduction scenario
- Expected vs actual behavior
- Minimal recommended fix

Do not praise code unless it is relevant to explaining a risk or tradeoff.