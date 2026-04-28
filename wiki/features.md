# Features

**Summary**: Snapshot of the currently implemented gameplay, UI, and content features in the Matchatro prototype.

**Sources**: `todo.md`, `docs/game_design_document.md`, `docs/test_plan.md`, `scripts/core/run_state.gd`, `scripts/combat/combat_state_machine.gd`, `scripts/content/content_registry.gd`, `scripts/shop/shop_service.gd`, `scripts/run/player_progression_service.gd`, `scripts/board/board_state.gd`, `scripts/board/board_view.gd`

**Last updated**: 2026-04-29

---

## Overview

The project already covers the early prototype loop: board generation, drag movement, match resolution, combat, shop flow, boss rewards, run sequencing, content packs, and the player-facing HUD. (source: `todo.md`, `docs/test_plan.md`, `scripts/core/run_state.gd`)

## Details

### Board and combat

- 5x6 orb board with six orb types, deterministic generation, and no starting automatic matches. (source: `scripts/board/board_state.gd`, `todo.md`)
- Drag-based orb movement and board rendering are handled by the board scene/controller path. (source: `scripts/board/board_view.gd`, `scripts/debug/board_debug_controller.gd`)
- Match resolution supports lines, L, T, gravity, refill, and cascades. (source: `docs/test_plan.md`, `scripts/board/board_match_resolver_v3.gd`)
- Combat resolves heart healing, armor gain, elemental damage, gold gain, block, and enemy death-before-intent behavior. (source: `scripts/combat/combat_state_machine.gd`, `docs/test_plan.md`)

### Run flow

- The run is a 3-level prototype with enemy, shop, boss, boss-reward, and advance steps. (source: `todo.md`, `scripts/core/run_state.gd`)
- Boss preview, boss relic reward, victory, and defeat flow are implemented in the run scene path. (source: `scripts/core/run_state.gd`, `scripts/flow/boss_relic_reward.gd`)

### Shop and progression

- The shop offers 3 random item slots and 1 relic offer per dungeon level, plus reroll, buying, selling, and booster selection. (source: `docs/game_design_document.md`, `scripts/shop/shop_service.gd`)
- Player progression tracks 5 equipment slots, 3 consumable slots, relic ownership, and 6 mastery tracks capped at 5. (source: `scripts/run/player_progression_state.gd`, `scripts/run/player_progression_service.gd`)

### Content pack

- The current content registry includes equipment, mastery cards, consumables, relics, enemies, and bosses. (source: `scripts/content/content_registry.gd`)
- The Milestone 8 content pack is already represented in code and validation, including 25 equipment items, 6 mastery cards, 6 consumables, 5 relics, 3 enemies, and 3 bosses. (source: `docs/test_plan.md`, `scripts/content/content_registry.gd`)

### UI and presentation

- Combat and shop now have player-facing scenes; combat HUD functionality is restored with plain visuals (art-heavy background, enemy portrait, and intent badge presentation removed) for the HUD revamp baseline. (source: `scenes/combat/combat_player.tscn`, `scripts/combat/combat_board_only_controller.gd`, `scripts/flow/shop_player.gd`)
- The visual registry provides the first-pass art lookup and fallback path for UI, backgrounds, and icons. (source: `scripts/ui/visual_registry.gd`)
- Combat HUD styling now prefers texture-backed chrome/bars and uses compact reference-style callouts for intent and combo bonus; build slots were enlarged and now display consumable/mastery counts in-slot. (source: `scripts/combat/combat_player_controller.gd`, `scenes/combat/combat_player.tscn`)
- Display viewport now defaults to portrait mobile (`1080x1920`) and combat HUD sections are enabled by default in `combat_player.tscn` with updated responsive sizing for portrait composition. (source: `project.godot`, `scenes/combat/combat_player.tscn`, `scripts/combat/combat_player_controller.gd`)
- Combat UI received a second polish pass for stronger visual hierarchy: larger headline typography, richer gold-accent panel chrome, thicker bars/buttons, clearer timer text, and rebalanced section heights for mobile portrait readability. (source: `scripts/combat/combat_player_controller.gd`, `scenes/combat/combat_player.tscn`)
- Combat layout now uses an explicit zone-height profile (`top/enemy/tempo/board/player`) to reduce dead space and speed up iterative polish; missing art areas now show stable placeholders for intent, enemy portrait, and hero portrait so alignment can be tuned before final assets. (source: `scripts/combat/combat_player_controller.gd`, `scenes/combat/combat_player.tscn`)
- Combat scene hierarchy now exposes first-class zone nodes (`TopBar`, `EnemyPanel`, `CombatStrip`, `BoardPanel`, `PlayerPanel`) so zone-specific polish can be done without path hunting. (source: `scenes/combat/combat_player.tscn`, `scripts/combat/combat_player_controller.gd`)
- Player zone internals are now split into explicit subzones (`PlayerStatsRow`, `CombatMetaRow`, `LoadoutRow`) and a debug zone-guide toggle (`F2`) can label core zones during polish passes. (source: `scenes/combat/combat_player.tscn`, `scripts/combat/combat_player_controller.gd`)
- Combat polish tuning is now centralized through controller constants for zone heights, board clamps, typography tiers, combo block width, and board offset bias, enabling rapid single-point iteration for mobile layout fitting. (source: `scripts/combat/combat_player_controller.gd`)
- Combat HUD layout now uses a dedicated `CombatLayoutRoot` with design-space rects at `1080x1920`; `_apply_combat_layout()` directly positions `TopBar`, `EnemyPanel`, `CombatStrip`, `BoardPanel`, and `PlayerPanel`, replacing the previous vertical container-driven layout. (source: `scenes/combat/combat_player.tscn`, `scripts/combat/combat_player_controller.gd`)

## Important Files

- `scripts/board/board_state.gd` - board data model
- `scripts/combat/combat_state_machine.gd` - turn resolution
- `scripts/core/run_state.gd` - run sequencing
- `scripts/content/content_registry.gd` - content pack and pools
- `scripts/shop/shop_service.gd` - shop actions
- `scripts/run/player_progression_service.gd` - progression transitions
- `scripts/combat/combat_player_controller.gd` - player-facing combat UI
- `scripts/flow/shop_player.gd` - player-facing shop UI

## Open Questions

- Which remaining QA items should be considered done only after manual validation on desktop and mobile. (source: `docs/test_plan.md`)

## Related Pages

- [[architecture]]
- [[setup]]
- [[file-map]]
- [[known-issues]]
