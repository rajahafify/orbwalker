# Known Issues

**Summary**: Current risks, validation gaps, and implementation mismatches that should stay visible while the prototype evolves.

**Sources**: `docs/test_plan.md`, `docs/system_architecture.md`, `scripts/shop/shop_service.gd`, `scripts/content/content_registry.gd`, `scripts/core/run_state.gd`

**Last updated**: 2026-05-03

---

## Overview

The prototype is functional, but several QA items remain unchecked and a few implementation gaps still need follow-up. (source: `docs/test_plan.md`)

## Details

- Touch input selection still needs explicit validation on device. The QA checklist keeps this item unchecked. (source: `docs/test_plan.md`)
- Board lock behavior during resolution and transitions still needs full end-to-end validation. (source: `docs/test_plan.md`)
- Desktop and mobile overlap checks for the UI remain open in the QA checklist. (source: `docs/test_plan.md`)
- Merchant Compass free-first-reroll behavior is still unchecked in the QA plan, and `scripts/shop/shop_service.gd` does not currently implement a special free reroll path. (source: `docs/test_plan.md`, `scripts/shop/shop_service.gd`)
- Full end-to-end manual playthrough of boss victory into relic choice into post-boss shop, plus final boss victory into run summary, remains useful after the 2026-05-02 overlay-route and modal layering changes, even though Godot MCP script, scene-tree, and runtime probes passed. (source: `docs/test_plan.md`, `scripts/combat/combat_player_controller.gd`, `scripts/core/run_state.gd`)
- `Start Run -> Combat` has a confirmed instantiate-time transition stall. Temporary FlowTrace logs show resource load around `213ms`, `PackedScene.instantiate()` around `2471ms`, and scene attach around `81ms` for `res://scenes/combat/combat_player.tscn`; audio and `_ready()` happen after attach and are currently small. The next step is isolated Godot editor-side instantiation probes for the combat scene, board surface, theme resources, and script initializers. (source: `scripts/core/run_state.gd`, `scripts/combat/combat_player_controller.gd`, `docs/tmp_transition_delay_handoff.md`)
- The architecture doc still describes Resource-based content classes, but the live code uses a dictionary-backed `ContentRegistry`. That mismatch should be tracked until the project chooses a final direction. (source: `docs/system_architecture.md`, `scripts/content/content_registry.gd`)
- Balance tuning is still open for orb spawn rates, prices, enemy stats, boss stats, and item strength. (source: `todo.md`, `docs/game_design_document.md`)

## Important Files

- `docs/test_plan.md` - current QA gaps
- `scripts/shop/shop_service.gd` - shop behavior and reroll logic
- `scripts/content/content_registry.gd` - current content model
- `docs/system_architecture.md` - planned content model
- `docs/tmp_transition_delay_handoff.md` - temporary transition-stall diagnostic handoff

## Open Questions

- Which of the remaining QA items should be treated as blockers versus post-prototype polish. (source: `docs/test_plan.md`)

## Related Pages

- [[architecture]]
- [[setup]]
- [[decisions]]
- [[open-questions]]
