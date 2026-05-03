# Architecture

**Summary**: Current runtime architecture for Orbwalker, grounded in the live scripts and the long-lived architecture doc. This page also records the current mismatch between the planned content model and the implemented one.

**Sources**: `docs/system_architecture.md`, `docs/architecture_review_tasks.md`, `scripts/core/run_state.gd`, `scripts/board/board_state.gd`, `scripts/board/board_view.gd`, `scripts/combat/combat_state_machine.gd`, `scripts/combat/combat_player_controller.gd`, `scripts/combat/combat_outcome_overlay.gd`, `scripts/content/content_registry.gd`, `scripts/shop/shop_service.gd`, `scripts/run/player_progression_state.gd`, `scripts/run/player_progression_service.gd`, `scripts/ui/visual_registry.gd`

**Last updated**: 2026-05-03

---

## Overview

The architecture is organized around state-owned gameplay logic and scene-driven presentation. `RunState` is the central autoload for run flow, scene routing, run gold, dungeon level, boss rewards, and encounter selection. `BoardState` owns the 5x6 grid. `CombatStateMachine` resolves turns. `ShopService` owns shop actions. `PlayerProgressionState` and `PlayerProgressionService` own equipment, consumables, relics, and mastery transitions. (source: `scripts/core/run_state.gd`, `scripts/board/board_state.gd`, `scripts/combat/combat_state_machine.gd`, `scripts/shop/shop_service.gd`, `scripts/run/player_progression_state.gd`, `scripts/run/player_progression_service.gd`)

## Details

### Run flow

- `RunState` tracks dungeon level, current step, current encounter, run gold, total gold earned, and the boss-reward sequence. It also chooses the next scene to load. (source: `scripts/core/run_state.gd`)
- The level structure is a 3-level prototype run with repeated enemy, shop, boss reward, and advance steps. (source: `todo.md`, `scripts/core/run_state.gd`)

### Board and combat

- `BoardState` is a pure data model with deterministic generation, bounds checks, swaps, and match-avoidant starting boards. (source: `scripts/board/board_state.gd`)
- `BoardView` is a render-and-animation surface. It draws the grid, selected cells, drag path, flashes, and glow overlays, but does not own board rules. (source: `scripts/board/board_view.gd`)
- `CombatStateMachine` resolves the turn order, applies player effects in the documented sequence, handles block and armor, and records a structured combat log. (source: `scripts/combat/combat_state_machine.gd`)
- `CombatPlayerController` owns combat scene orchestration, input, resolver replay timing, RunState outcome routing, audio hooks, and debug commands. `CombatOutcomeOverlay` owns only the combat outcome overlay presentation boundary: standard victory/defeat card state, boss reward card controls, scrim layering, card layout/content, and text wrapping. (source: `scripts/combat/combat_player_controller.gd`, `scripts/combat/combat_outcome_overlay.gd`)

### Shop and progression

- `ShopService` opens shops, rerolls offers, buys items, sells equipped items, and resolves booster picks through `RunState` and the progression service. (source: `scripts/shop/shop_service.gd`)
- `PlayerProgressionState` stores equipped items, consumables, relics, and mastery levels. `PlayerProgressionService` performs the legal transitions and rebuilds active effects. (source: `scripts/run/player_progression_state.gd`, `scripts/run/player_progression_service.gd`)

### Content and validation

- `ContentRegistry` currently stores content as nested dictionaries and validates required fields and effect hooks. It also builds shop pools and pricing snapshots. (source: `scripts/content/content_registry.gd`)
- This differs from the planned Resource-based content model described in `docs/system_architecture.md`. The design doc still reflects the intended target, but the live code is dictionary-backed today. (source: `docs/system_architecture.md`, `scripts/content/content_registry.gd`)

### Visual routing

- `visual_registry.gd` centralizes first-pass texture lookup and fallback behavior for combat and shop presentation. (source: `scripts/ui/visual_registry.gd`)

## Important Files

- `scripts/core/run_state.gd` - run orchestration and scene routing
- `scripts/content/content_registry.gd` - content data, validation, and pools
- `scripts/combat/combat_state_machine.gd` - combat turn resolution
- `scripts/combat/combat_outcome_overlay.gd` - combat outcome and boss reward overlay presentation helper
- `scripts/shop/shop_service.gd` - shop generation and purchases
- `scripts/run/player_progression_service.gd` - equip, sell, mastery, consumable, and relic transitions
- `docs/system_architecture.md` - original architecture target and planned data model
- `docs/architecture_review_tasks.md` - architecture-maintenance task tracker for refactor risks, regression harness work, and current/future architecture alignment

## Open Questions

- Whether the content model should remain dictionary-backed or move to Resource classes later. (source: `docs/system_architecture.md`, `scripts/content/content_registry.gd`)

## Related Pages

- [[setup]]
- [[file-map]]
- [[features]]
- [[decisions]]
- [[known-issues]]
