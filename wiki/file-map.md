# File Map

**Summary**: High-level map of the important folders and files in the current Orbwalker checkout.

**Sources**: `project.godot`, `todo.md`, `docs/system_architecture.md`, `scenes/main.tscn`, `scenes/combat/board_debug.tscn`, `scenes/combat/combat_player.tscn`, `scenes/board/board_surface.tscn`, `scenes/flow/shop_player.tscn`, `scenes/flow/boss_relic_reward.tscn`, `scripts/core/run_state.gd`, `scripts/board/board_state.gd`, `scripts/board/board_surface.gd`, `scripts/combat/combat_state_machine.gd`, `scripts/content/content_registry.gd`, `scripts/run/player_progression_service.gd`, `scripts/shop/shop_service.gd`, `scripts/ui/player_loadout_hud.gd`, `scripts/debug/board_debug_controller.gd`, `resources/art/first_pass/`, `resources/content/`, `resources/visual/`

**Last updated**: 2026-04-29

---

## Overview

The repository is a Godot project with scenes, gameplay scripts, first-pass art, and content assets already separated into focused folders. (source: `project.godot`, repository layout)

## Details

- `scenes/` - Scene entry points and player-facing flow. Important files include `scenes/main.tscn`, `scenes/combat/board_debug.tscn`, `scenes/combat/combat_player.tscn`, reusable board surface `scenes/board/board_surface.tscn`, `scenes/flow/shop_player.tscn`, `scenes/flow/boss_relic_reward.tscn`, and the placeholder run summary/shop scenes. The combat scene now contains explicit mobile HUD zones, a timer-only strip, and a reference-style player panel with `HeroCard`, `VitalsPanel`, `LoadoutFrame`, and `MasteryStrip`. (source: repository layout, `scripts/core/run_state.gd`, `scenes/combat/combat_player.tscn`)
- `scripts/core/` - Global run orchestration and shared startup logic. `run_state.gd` is the main autoload-backed controller, and `main_boot.gd` handles the main menu launch. (source: `scripts/core/run_state.gd`, `scripts/core/main_boot.gd`)
- `scripts/board/` - Board model, generation settings, orb typing, match resolver, board rendering, and board surface wrapper script for scene composition reuse. (source: `scripts/board/board_state.gd`, `scripts/board/board_view.gd`, `scripts/board/board_surface.gd`)
- `scripts/combat/` - Combat state machine, player state, enemy state, and the combat scene controller. (source: `scripts/combat/combat_state_machine.gd`, `scripts/combat/combat_player_controller.gd`)
- `scripts/content/` - Content registry and validation. (source: `scripts/content/content_registry.gd`)
- `scripts/run/` - Player progression state and service. (source: `scripts/run/player_progression_state.gd`, `scripts/run/player_progression_service.gd`)
- `scripts/shop/` - Shop state and shop service. (source: `scripts/shop/shop_state.gd`, `scripts/shop/shop_service.gd`)
- `scripts/flow/` - Transition and flow controllers for shop, boss relic reward, and summary surfaces. (source: `scripts/flow/boss_relic_reward.gd`, `scripts/flow/shop_player.gd`, `scripts/flow/run_summary_placeholder.gd`, `scripts/flow/shop_placeholder.gd`)
- `scripts/debug/` - Debug controller and resolver test runner. (source: `scripts/debug/board_debug_controller.gd`, `scripts/debug/board_resolver_test_runner.gd`)
- `scripts/ui/` - Shared presentation helpers such as the visual registry and reusable player loadout/mastery HUD renderer. (source: `scripts/ui/visual_registry.gd`, `scripts/ui/player_loadout_hud.gd`)
- `tools/asset_tools/` - Utility scripts for asset extraction and cleanup, including HUD slicing, derived icon alpha cleanup, and generated main-menu chrome/icon alpha cleanup. (source: `tools/asset_tools/hud_extractor.gd`, `tools/asset_tools/clean_derived_icons.py`, `tools/asset_tools/clean_menu_art.py`)
- `resources/art/first_pass/` - First-pass backgrounds, enemy portraits, UI sheets, VFX, derived icons, and the new `menu/` art package for the main menu background, logo, border, button plates, stat panel, and menu symbols. (source: repository layout, `resources/art/first_pass/menu/`)
- `resources/content/` - Content asset folders reserved for equipment, mastery, consumables, relics, boosters, enemies, bosses, and pricing. The current runtime content is still dictionary-backed, so these folders are not the primary source of truth yet. (source: `docs/system_architecture.md`, `scripts/content/content_registry.gd`)
- `resources/visual/` - First-pass visual asset map and theme resource. `resources/visual/first_pass_asset_map.json` now includes the main menu art package as a dedicated mapping block. (source: repository layout, `resources/visual/first_pass_asset_map.json`)
- `docs/` - Human-facing design, architecture, and QA docs. (source: `docs/game_design_document.md`, `docs/system_architecture.md`, `docs/test_plan.md`)
- `todo.md` - Milestone and scope tracker for prototype work. (source: `todo.md`)

## Important Files

- `project.godot` - project entry and autoload configuration
- `todo.md` - milestone scope and status tracker
- `scenes/main.tscn` - startup scene
- `scripts/core/run_state.gd` - central runtime controller
- `scripts/content/content_registry.gd` - content data source and validation
- `scripts/ui/player_loadout_hud.gd` - shared combat/shop player loadout and mastery renderer

## Open Questions

- Whether the reserved `resources/content/` folders will become the long-term content source or remain staging areas. (needs verification)

## Related Pages

- [[setup]]
- [[architecture]]
- [[features]]
