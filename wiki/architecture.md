# Architecture

**Summary**: Current runtime architecture for Orbwalker, grounded in the live scripts and the long-lived architecture doc. This page also records the current mismatch between the planned content model and the implemented one.

**Sources**: `docs/system_architecture.md`, `docs/architecture_review_tasks.md`, `scripts/core/run_state.gd`, `scripts/board/board_state.gd`, `scripts/board/board_view.gd`, `scripts/combat/combat_state_machine.gd`, `scripts/combat/combat_player_controller.gd`, `scripts/combat/board_drag_input_handler.gd`, `scripts/combat/combat_layout_manager.gd`, `scripts/combat/combat_vfx_manager.gd`, `scripts/combat/combat_outcome_overlay.gd`, `scripts/content/content_registry.gd`, `scripts/shop/shop_service.gd`, `scripts/run/player_progression_state.gd`, `scripts/run/player_progression_service.gd`, `scripts/ui/visual_registry.gd`

**Last updated**: 2026-05-04

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
- `CombatPlayerController` owns combat scene orchestration, input phase authority, resolver simulation, combat math handoff, RunState outcome routing, audio hooks, `/skip` route/state reset, privileged debug callbacks, HUD snapshot application and `PlayerLoadoutHud` payload dispatch, timer runtime text/fill/color math, placeholder fallback decisions and scene-node assignment, VFX timing decisions, and scene transitions. `CombatHudSnapshotBuilder` owns side-effect-free combat HUD snapshot dictionary construction for top HUD, enemy stage, timer/tempo row, player strip, and debug overlay data. `CombatPlaceholderTextures` owns only the code-generated timer, intent, enemy portrait, and hero portrait placeholder texture builders. `CombatChromeStyler` owns code-built combat chrome/style construction, including shared combat frame styleboxes, progress-bar styles, label font/color overrides, timer-track and timer-label readability styling, button chrome, board/outcome panel chrome, stat-chip chrome, debug overlay font sizing, shared player-HUD chrome dispatch, and debug zone-guide chrome. `BoardDragInputHandler` owns board-local mouse/touch event parsing, active drag state, touch-index tracking, selected orb/current cell/path tracking, adjacent-cell swap bookkeeping, move-timer countdown state, drag visual reset/abort, and match-glow refresh while preserving `BoardView.gui_input` local coordinates. `CombatLayoutManager` owns combat scene geometry and responsive design-space positioning, including design-root scaling, runtime zone rects, enemy/strip/board/player panel positioning, loadout rail positioning, debug overlay anchors, and outcome overlay layout sync. `CombatVfxManager` owns transient combat VFX drawing mechanics: VFX layer binding, texture VFX spawning, replay impacts, mastery beam source lookup, global-to-layer coordinate conversion, beam sizing/rotation/z-index, and fade cleanup. `CombatDebugConsole` owns debug command parsing/dispatch, command help/error text, log-level state, and combat log rendering. `CombatTurnLogger` owns normal/detailed turn-log text, state snapshot formatting helpers, intent text, and reusable outcome/summary strings. `CombatResolvePresenter` owns only the board-space resolve replay presentation boundary: sorted match presentation order, match flash waits, clear/gravity/refill animation timing, visual board commits, clear bursts, combo popup lifecycle, and `combat_speed` waits. `CombatOutcomeOverlay` owns only the combat outcome overlay presentation boundary: standard victory/defeat card state, boss reward card controls, scrim layering, card layout/content, and text wrapping. (source: `scripts/combat/combat_player_controller.gd`, `scripts/combat/combat_hud_snapshot_builder.gd`, `scripts/combat/combat_placeholder_textures.gd`, `scripts/combat/combat_chrome_styler.gd`, `scripts/combat/board_drag_input_handler.gd`, `scripts/combat/combat_layout_manager.gd`, `scripts/combat/combat_vfx_manager.gd`, `scripts/combat/combat_debug_console.gd`, `scripts/combat/combat_turn_logger.gd`, `scripts/combat/combat_resolve_presenter.gd`, `scripts/combat/combat_outcome_overlay.gd`)

### Shop and progression

- `ShopService` opens shops, rerolls offers, buys items, sells equipped items, and resolves booster picks through `RunState` and the progression service. (source: `scripts/shop/shop_service.gd`)
- `PlayerProgressionState` stores equipped items, consumables, relics, and mastery levels. `PlayerProgressionService` performs the legal transitions and rebuilds active effects. (source: `scripts/run/player_progression_state.gd`, `scripts/run/player_progression_service.gd`)

### Content and validation

- `ContentRegistry` currently stores content as nested dictionaries and validates required fields and effect hooks. It also builds shop pools and pricing snapshots. `content_contract_snapshot()` records the current collection fields, validation owner, shop pool/pricing owner, and future migration boundary. Single-item getters and list APIs return duplicated dictionaries so callers cannot mutate the registry index by accident. (source: `scripts/content/content_registry.gd`)
- Dictionary-backed `ContentRegistry` content is the prototype source of truth for this phase. The older Resource-based architecture direction is now documented as future migration work that should stay behind the `ContentRegistry` read API instead of changing combat, shop, progression, HUD, or debug callers directly. (source: `docs/system_architecture.md`, `scripts/content/content_registry.gd`)

### Visual routing

- `visual_registry.gd` centralizes first-pass texture lookup and fallback behavior for combat and shop presentation. (source: `scripts/ui/visual_registry.gd`)

## Important Files

- `scripts/core/run_state.gd` - run orchestration and scene routing
- `scripts/content/content_registry.gd` - content data, validation, and pools
- `scripts/combat/board_drag_input_handler.gd` - board-local drag/pointer input state helper
- `scripts/combat/combat_chrome_styler.gd` - combat code-built chrome and style helper
- `scripts/combat/combat_hud_snapshot_builder.gd` - side-effect-free combat HUD snapshot dictionary builder
- `scripts/combat/combat_placeholder_textures.gd` - combat code-generated placeholder texture builder helper
- `scripts/combat/combat_state_machine.gd` - combat turn resolution
- `scripts/combat/combat_layout_manager.gd` - combat scene geometry and responsive design-space layout helper
- `scripts/combat/combat_vfx_manager.gd` - combat transient VFX spawning, impact, beam, coordinate conversion, and fade cleanup helper
- `scripts/combat/combat_resolve_presenter.gd` - board-space resolve replay presentation helper
- `scripts/combat/combat_debug_console.gd` - combat debug command parser and log renderer
- `scripts/combat/combat_turn_logger.gd` - combat turn-log and outcome summary formatter
- `scripts/combat/combat_outcome_overlay.gd` - combat outcome and boss reward overlay presentation helper
- `scripts/shop/shop_service.gd` - shop generation and purchases
- `scripts/run/player_progression_service.gd` - equip, sell, mastery, consumable, and relic transitions
- `docs/system_architecture.md` - original architecture target and planned data model
- `docs/architecture_review_tasks.md` - architecture-maintenance task tracker for refactor risks, regression harness work, and current/future architecture alignment

## Open Questions

- Whether a later content migration should use Resource classes, JSON, or another external data source. The current prototype remains dictionary-backed behind `ContentRegistry`. (source: `docs/system_architecture.md`, `scripts/content/content_registry.gd`)

## Related Pages

- [[setup]]
- [[file-map]]
- [[features]]
- [[decisions]]
- [[known-issues]]
