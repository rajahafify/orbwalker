# Known Issues

**Summary**: Current risks, validation gaps, and implementation mismatches that should stay visible while the prototype evolves.

**Sources**: `docs/test_plan.md`, `docs/system_architecture.md`, `scripts/shop/shop_service.gd`, `scripts/content/content_registry.gd`, `scripts/core/run_state.gd`

**Last updated**: 2026-04-28

---

## Overview

The prototype is functional, but several QA items remain unchecked and a few implementation gaps still need follow-up. (source: `docs/test_plan.md`)

## Details

- Touch input selection still needs explicit validation on device. The QA checklist keeps this item unchecked. (source: `docs/test_plan.md`)
- Board lock behavior during resolution and transitions still needs full end-to-end validation. (source: `docs/test_plan.md`)
- Desktop and mobile overlap checks for the UI remain open in the QA checklist. (source: `docs/test_plan.md`)
- Merchant Compass free-first-reroll behavior is still unchecked in the QA plan, and `scripts/shop/shop_service.gd` does not currently implement a special free reroll path. (source: `docs/test_plan.md`, `scripts/shop/shop_service.gd`)
- The architecture doc still describes Resource-based content classes, but the live code uses a dictionary-backed `ContentRegistry`. That mismatch should be tracked until the project chooses a final direction. (source: `docs/system_architecture.md`, `scripts/content/content_registry.gd`)
- Balance tuning is still open for orb spawn rates, prices, enemy stats, boss stats, and item strength. (source: `todo.md`, `docs/game_design_document.md`)

## Important Files

- `docs/test_plan.md` - current QA gaps
- `scripts/shop/shop_service.gd` - shop behavior and reroll logic
- `scripts/content/content_registry.gd` - current content model
- `docs/system_architecture.md` - planned content model

## Open Questions

- Which of the remaining QA items should be treated as blockers versus post-prototype polish. (source: `docs/test_plan.md`)

## Related Pages

- [[architecture]]
- [[setup]]
- [[decisions]]
- [[open-questions]]

