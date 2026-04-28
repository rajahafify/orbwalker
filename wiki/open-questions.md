# Open Questions

**Summary**: Remaining design and implementation questions that are not fully resolved by the current sources.

**Sources**: `docs/game_design_document.md`, `docs/system_architecture.md`, `docs/test_plan.md`, `todo.md`, `scripts/content/content_registry.gd`, `scripts/shop/shop_service.gd`

**Last updated**: 2026-04-28

---

## Overview

These are the questions the project still needs to answer during balance, QA, or later refactors. (source: `docs/game_design_document.md`, `docs/system_architecture.md`, `todo.md`)

## Details

- What exact gold orb spawn rate should the prototype use? (source: `docs/game_design_document.md`, `todo.md`)
- What should the final shop price bands and reroll cost curve be? (source: `docs/game_design_document.md`, `todo.md`)
- Should Merchant Compass make the first reroll free, and if so, where should that rule live? (source: `docs/game_design_document.md`, `docs/test_plan.md`, `scripts/shop/shop_service.gd`)
- Should the movement timer stay at 5 seconds after mobile testing? (source: `docs/game_design_document.md`, `docs/system_architecture.md`)
- Should L and T matches ever grant a bonus beyond the matched orb count? (source: `docs/game_design_document.md`, `docs/system_architecture.md`)
- Should the content model stay dictionary-backed for the prototype or migrate to Resource classes later? (source: `docs/system_architecture.md`, `scripts/content/content_registry.gd`)
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

