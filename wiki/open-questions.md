# Open Questions

**Summary**: Remaining design and implementation questions that are not fully resolved by the current sources.

**Sources**: `docs/game_design_document.md`, `docs/system_architecture.md`, `docs/test_plan.md`, `todo.md`, `scripts/content/content_registry.gd`, `scripts/shop/shop_service.gd`

**Last updated**: 2026-05-05

---

## Overview

These questions have been resolved for the current first playable scope or transferred to the itch.io readiness tracker when they can affect public launch. Longer-term refactor/content questions remain future work, not active launch blockers. (source: `docs/game_design_document.md`, `docs/system_architecture.md`, `todo.md`, `docs/itch_readiness_tasks.md`)

## Details

- Closed for first playable: Gold spawn and temporary economy balance use the M10 accepted playtest scaffolding. Final tuning can be reopened after itch readiness if player evidence requires it. (source: `docs/game_design_document.md`, `todo.md`, `docs/milestone_10_balance_tasks.md`)
- Closed for first playable: Shop price bands and paid reroll curve use the M10 accepted temporary values. Merchant Compass free-first-reroll is transferred to ITCH-04. (source: `docs/game_design_document.md`, `todo.md`, `docs/milestone_10_balance_tasks.md`, `docs/itch_readiness_tasks.md`, `scripts/shop/shop_service.gd`)
- Transferred to ITCH-01/ITCH-08: The 5 second movement timer remains the first playable default; target-device comfort validation now lives in the itch readiness tracker. (source: `docs/game_design_document.md`, `docs/system_architecture.md`, `docs/itch_readiness_tasks.md`)
- Closed for first playable: L and T matches do not grant extra bonuses beyond matched orb count unless future playtesting reopens the design. (source: `docs/game_design_document.md`, `docs/system_architecture.md`)
- Deferred future architecture: External content migration from dictionary-backed prototype content to Resource classes, JSON, or another format is not an itch readiness blocker. (source: `docs/system_architecture.md`, `scripts/content/content_registry.gd`)
- Closed here: launch-blocker classification moved to `docs/itch_readiness_tasks.md`. (source: `docs/test_plan.md`, `docs/itch_readiness_tasks.md`)

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
