# Decisions

**Summary**: Long-lived implementation decisions that affect how the prototype is structured and maintained.

**Sources**: `docs/system_architecture.md`, `todo.md`, `project.godot`, `scripts/core/run_state.gd`, `scripts/content/content_registry.gd`, `scripts/shop/shop_service.gd`, `scripts/run/player_progression_service.gd`

**Last updated**: 2026-04-28

---

## Overview

This page records decisions that are already reflected in the code or explicitly documented as the project direction. It also captures the current content-model mismatch so it does not get lost. (source: `docs/system_architecture.md`, `scripts/content/content_registry.gd`)

## Details

### 2026-04-28 - Use RunState As The Run Orchestrator

**Decision**: `RunState` is the central autoload for run-level state, scene routing, dungeon progression, run gold, and boss reward flow.

**Reason**: The live code already routes combat, shop, boss reward, and summary transitions through a single runtime owner, which keeps the run flow deterministic and easy to inspect.

**Alternatives considered**: Distribute scene routing across individual scenes or controllers.

**Consequences**: Run flow is centralized, which simplifies validation, but `RunState` is now a high-value integration point that needs careful compatibility handling.

**Sources**: `project.godot`, `scripts/core/run_state.gd`, `scripts/flow/boss_relic_reward.gd`, `scripts/flow/shop_player.gd`

### 2026-04-28 - Keep The Current Dictionary-Backed Content Registry

**Decision**: The live prototype uses dictionary-backed content data inside `ContentRegistry` instead of the Resource-based content classes described in the architecture draft.

**Reason**: The codebase already relies on dictionary content for validation, shop pools, and progression transitions, and the current prototype is moving faster with that simpler representation.

**Alternatives considered**: Migrate now to Resource subclasses for equipment, mastery, consumables, relics, enemies, and bosses.

**Consequences**: The current implementation is less editor-native than the planned model, but it is consistent across combat, shop, and progression code. A later migration would need a compatibility pass.

**Sources**: `docs/system_architecture.md`, `scripts/content/content_registry.gd`, `scripts/shop/shop_service.gd`, `scripts/run/player_progression_service.gd`

### 2026-04-28 - Keep The 3-Level First Playable Scope

**Decision**: The first playable prototype remains a 3-level run, not the full 10-level GDD loop.

**Reason**: The milestone tracker and architecture doc both define the current scope as a vertical slice.

**Alternatives considered**: Expand the initial implementation to the full 10-level structure.

**Consequences**: Balance and content can be validated sooner, but later milestones will still need run-length expansion work.

**Sources**: `todo.md`, `docs/system_architecture.md`, `docs/game_design_document.md`

## Important Files

- `scripts/core/run_state.gd` - run ownership decision point
- `scripts/content/content_registry.gd` - current content model implementation
- `docs/system_architecture.md` - planned architecture reference

## Open Questions

- Whether the content model should be migrated from dictionaries to Resources later. (source: `docs/system_architecture.md`, `scripts/content/content_registry.gd`)

## Related Pages

- [[architecture]]
- [[features]]
- [[known-issues]]
