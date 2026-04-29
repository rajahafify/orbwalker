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
- Combat strip is now timer-only: a centered unified `TimerTrack` slab contains the generated hourglass icon, timer value, state label, and draining fill layer (combo/damage panel removed). (source: `scripts/combat/combat_player_controller.gd`, `scenes/combat/combat_player.tscn`)
- Display viewport now defaults to portrait mobile (`1080x1920`) and combat HUD sections are enabled by default in `combat_player.tscn` with updated responsive sizing for portrait composition. (source: `project.godot`, `scenes/combat/combat_player.tscn`, `scripts/combat/combat_player_controller.gd`)
- Combat UI received a second polish pass for stronger visual hierarchy: larger headline typography, richer gold-accent panel chrome, thicker bars/buttons, clearer timer text, and rebalanced section heights for mobile portrait readability. (source: `scripts/combat/combat_player_controller.gd`, `scenes/combat/combat_player.tscn`)
- Combat move timer now uses `READY`, `MOVE`, `WARN`, `CRIT`, and `LOCK` presentation states with integer countdown above 2s, tenth-second countdown below 2s, and live safe/warning/critical color transitions across the track fill and labels. (source: `scripts/combat/combat_player_controller.gd`)
- Combat layout now uses an explicit zone-height profile (`top/enemy/tempo/board/player`) to reduce dead space and speed up iterative polish; missing art areas now show stable placeholders for intent, enemy portrait, and hero portrait so alignment can be tuned before final assets. (source: `scripts/combat/combat_player_controller.gd`, `scenes/combat/combat_player.tscn`)
- Combat scene hierarchy now exposes first-class zone nodes (`TopBar`, `EnemyPanel`, `CombatStrip`, `BoardPanel`, `PlayerPanel`) so zone-specific polish can be done without path hunting. (source: `scenes/combat/combat_player.tscn`, `scripts/combat/combat_player_controller.gd`)
- Player zone internals are now split into explicit reference-style subzones (`HeroCard`, `VitalsPanel`, `StatChipRow`, `LoadoutFrame`, `MasteryStrip`) and a debug zone-guide toggle (`F2`) can label core zones during polish passes. (source: `scenes/combat/combat_player.tscn`, `scripts/combat/combat_player_controller.gd`)
- Player loadout now renders as a compact always-visible rail with 5 equipment slots and 3 consumable slots; empty slots use dim framed placeholders and filled equipment/consumable slots show value/count badges. (source: `scripts/combat/combat_player_controller.gd`, `scenes/combat/combat_player.tscn`)
- Combat HUD layout now uses a dedicated `CombatLayoutRoot` with design-space rects at `1080x1920`; `_apply_combat_layout()` directly positions `TopBar`, `EnemyPanel`, `CombatStrip`, `BoardPanel`, and `PlayerPanel`, replacing the previous vertical container-driven layout. (source: `scenes/combat/combat_player.tscn`, `scripts/combat/combat_player_controller.gd`)
- Combat board presentation now includes a dark drop-shadow panel behind the board and a hidden centered board-level outcome summary card; victory/debug victory shows `Victory`, `GOLD GAINED +N`, and a large `Continue` button there instead of in the player HUD. (source: `scenes/combat/combat_player.tscn`, `scripts/combat/combat_player_controller.gd`)
- Combat debug overlay uses explicit larger debug typography and a taller console input field for command readability during in-editor testing. (source: `scenes/combat/combat_player.tscn`, `scripts/combat/combat_player_controller.gd`)
- Player panel now follows a simplified reference bottom-HUD structure with a larger hero portrait card, long primary HP bar, large always-visible equipment and consumable rails, and a full-width mastery strip with icon-plus-number cells; armor, stat chips, combat meta, turn summary rows, and the old level badge are hidden from the player panel. (source: `scenes/combat/combat_player.tscn`, `scripts/combat/combat_player_controller.gd`)
- Combat player section cohesion pass added a framed vitals block, `HP current / max` bar label, conditional Slay the Spire-inspired armor badge (`BLOCK +N` shown only when armor > 0), recessed silhouette empty-slot treatment for equipment/consumables, and a fixed mastery strip with inline `icon + numeric value` pairs for clearer non-debug readability. (source: `scenes/combat/combat_player.tscn`, `scripts/combat/combat_player_controller.gd`)

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
