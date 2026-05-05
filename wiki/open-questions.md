# Open Questions

**Summary**: Remaining design and implementation questions that are not fully resolved by the current sources.

**Sources**: `docs/game_design_document.md`, `docs/system_architecture.md`, `docs/test_plan.md`, `todo.md`, `scripts/content/content_registry.gd`, `scripts/shop/shop_service.gd`

**Last updated**: 2026-05-05

---

## Overview

These are the questions the project still needs to answer during balance, QA, or later refactors. (source: `docs/game_design_document.md`, `docs/system_architecture.md`, `todo.md`)

## Details

- What exact gold orb spawn rate should the final prototype use? Milestone 10 kept Gold spawn neutral and used temporary fixed fight rewards for playtest access; final tuning should wait until after Milestone 11 meta progression changes power and economy pressure. (source: `docs/game_design_document.md`, `todo.md`, `docs/milestone_10_balance_tasks.md`)
- What should the final shop price bands and reroll cost curve be? Milestone 10 has temporary shop-access scaffolding, including first-shop `Shortsword`, guaranteed booster presence, equipment-heavy stock, and rare consumables; final price/reroll tuning remains post-meta work. (source: `docs/game_design_document.md`, `todo.md`, `docs/milestone_10_balance_tasks.md`, `scripts/shop/shop_service.gd`)
- Should Merchant Compass make the first reroll free, and if so, where should that rule live? (source: `docs/game_design_document.md`, `docs/test_plan.md`, `scripts/shop/shop_service.gd`)
- Should the movement timer stay at 5 seconds after mobile testing? (source: `docs/game_design_document.md`, `docs/system_architecture.md`)
- Should L and T matches ever grant a bonus beyond the matched orb count? (source: `docs/game_design_document.md`, `docs/system_architecture.md`)
- Which external content data source, if any, should replace dictionary-backed prototype content after the current phase: Resource classes, JSON, or another format? (source: `docs/system_architecture.md`, `scripts/content/content_registry.gd`)
- Which remaining QA items from `docs/test_plan.md` should block the first playable milestone? (source: `docs/test_plan.md`)

## Important Files

- `docs/game_design_document.md` - source design questions
- `docs/system_architecture.md` - planned architecture decisions
- `docs/test_plan.md` - unresolved QA items
- `scripts/content/content_registry.gd` - current content model
- `scripts/shop/shop_service.gd` - shop and reroll behavior

## Related Pages

- [[decisions]]
- [[known-issues]]
- [[architecture]]
