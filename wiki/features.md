# Features

**Summary**: Snapshot of the currently implemented gameplay, UI, and content features in the Orbwalker prototype.

**Sources**: `todo.md`, `docs/game_design_document.md`, `docs/test_plan.md`, `scenes/main.tscn`, `scripts/core/main_boot.gd`, `scripts/core/run_state.gd`, `scripts/combat/combat_state_machine.gd`, `scripts/content/content_registry.gd`, `scripts/shop/shop_service.gd`, `scripts/run/player_progression_service.gd`, `scripts/board/board_state.gd`, `scripts/board/board_view.gd`, `scripts/ui/player_loadout_hud.gd`

**Last updated**: 2026-05-01

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

- Combat and shop now use player-facing scenes with wired character portraits: combat enemy portrait resolves from encounter `enemy_id`, combat hero portrait resolves from a shared Orbwalker hero texture, and shop footer reuses the same hero portrait accessor. (source: `scenes/combat/combat_player.tscn`, `scripts/combat/combat_player_controller.gd`, `scripts/flow/shop_player.gd`, `scripts/ui/visual_registry.gd`)
- Shop UI now uses a reference-style merchant layout with a top run/gold bar, merchant stage, 3 stock offer cards, a premium relic card, large reroll/sell/continue actions, selectable equipment sell slots, a booster choice overlay, and a combat-style player HUD footer. The footer uses the same shared player-panel geometry as combat instead of the old shop-only build panel. (source: `scenes/flow/shop_player.tscn`, `scripts/flow/shop_player.gd`, `scripts/ui/player_loadout_hud.gd`)
- Combat and shop player HUDs share `PlayerLoadoutHud`, which provides combat player-panel layout geometry plus equipment slots, consumable slots, relic icons, mastery cells, empty-slot silhouettes, and equipment badges from current progression content. (source: `scripts/ui/player_loadout_hud.gd`, `scripts/combat/combat_player_controller.gd`, `scripts/flow/shop_player.gd`)
- The visual registry provides first-pass art lookup and fallback paths for UI, backgrounds, icons, enemy portraits, and shared hero portraits; runtime encounter IDs now include `cavern_striker`, `cavern_defender`, `ash_hunter`, `ruin_lancer`, `vault_executioner`, `goldbound_keeper`, `iron_gate`, `burning_knight`, `prism_warden`, and fallback `training_goblin`. (source: `scripts/ui/visual_registry.gd`, `scripts/core/run_state.gd`)
- The main menu now has a dedicated first-pass art package under `resources/art/first_pass/menu/`, and the visual asset map documents the background, logo, border, button plates, stat panel, and menu icon set. The six elemental row icons reuse the existing mastery icon family. (source: `resources/art/first_pass/menu/`, `resources/visual/first_pass_asset_map.json`, `resources/art/first_pass/derived/icons/mastery_fire.png`, `resources/art/first_pass/derived/icons/mastery_ice.png`, `resources/art/first_pass/derived/icons/mastery_earth.png`, `resources/art/first_pass/derived/icons/mastery_heart.png`, `resources/art/first_pass/derived/icons/mastery_armor.png`, `resources/art/first_pass/derived/icons/mastery_gold.png`)
- Main menu runtime now uses an authored portrait scene composition with fixed design-space zones for logo/menu/element row/stats/footer and textured menu chrome from the mapped art package: `menu.outer_border`, `menu.button_primary`, `menu.button_secondary`, `menu.stats_panel`, and `menu.menu_icons`. `Start Run` remains functional; `Continue`, `Collection`, `Settings`, `Quit`, `Profile`, and `Achievements` remain disabled placeholders. (source: `scenes/main.tscn`, `scripts/core/main_boot.gd`, `resources/visual/first_pass_asset_map.json`)
- Main menu runtime applies explicit texture-size containment (`EXPAND_IGNORE_SIZE`), safe-area coordinate remapping, and icon size clamping so logo/element/stats/footer controls no longer expand beyond viewport bounds or overlap each other at the default portrait resolution. (source: `scripts/core/main_boot.gd`, `docs/test_plan.md`)
- Main menu generated chrome and menu icons now have real transparent alpha instead of baked checkerboard backgrounds, so the dungeon background remains visible behind the ornate border, button plates, stats panel, and footer/action icons. (source: `tools/asset_tools/clean_menu_art.py`, `resources/art/first_pass/menu/`, `docs/test_plan.md`)
- Derived equipment/mastery/relic icons were reprocessed to remove baked checkerboard backgrounds, restore alpha transparency, and normalize icon canvas sizing for cleaner slot/card rendering. (source: `tools/asset_tools/clean_derived_icons.py`, `resources/art/first_pass/derived/icons/`)
- Combat and shop now use compact owned-relic token rows with overflow (`+N`) handling so relic ownership is readable without consuming full footer space. (source: `scripts/ui/player_loadout_hud.gd`, `scripts/combat/combat_player_controller.gd`, `scripts/flow/shop_player.gd`)
- Boss relic reward options now render as visual cards (icon, rarity tint, description) instead of plain text buttons, while keeping the existing reward claim flow. (source: `scripts/flow/boss_relic_reward.gd`)
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
- Combat board now shows floating combo text near each resolved match group during cascades, with combo count increasing by resolve order and emitted per resolve pass in the animation loop so cascade combos are visible at the correct time. (source: `scripts/combat/combat_player_controller.gd`, `scripts/board/board_match_resolver_v3.gd`)
- Combat resolve now enables the shared `VfxLayer` at runtime and plays orb-clear bursts on the visible animation pass next to the combo text, so the board readout feels more immediate during clears. (source: `scripts/combat/combat_player_controller.gd`, `scenes/combat/combat_player.tscn`)
- Combat debug overlay uses explicit larger debug typography and a taller console input field for command readability during in-editor testing. (source: `scenes/combat/combat_player.tscn`, `scripts/combat/combat_player_controller.gd`)
- Player panel now follows a simplified reference bottom-HUD structure with a larger hero portrait card, long primary HP bar, and large always-visible equipment and consumable rails; armor, stat chips, combat meta, turn summary rows, the old level badge, and the former bottom mastery strip are hidden from the player panel. (source: `scenes/combat/combat_player.tscn`, `scripts/combat/combat_player_controller.gd`)
- Combat now has a compact `ElementalMasteryPanel` rail between the board and player HUD. The live combat layout uses a `1048 x 172` flat panel with six compact `132 x 104` mastery cards, real main-menu mastery iconography, readable name/level lanes, and retained transient `+N DAMAGE`, `+N HEAL`, `+N ARMOR`, or `+N GOLD` feedback text. After cascades finish, card effects still replay left-to-right from `turn_log` with beams/shell/impact VFX, block-before-HP enemy damage, player heal/armor/gold feedback, and enemy attack armor-before-HP replay. (source: `scenes/combat/combat_player.tscn`, `scripts/combat/combat_player_controller.gd`, `scripts/ui/player_loadout_hud.gd`, `scripts/ui/visual_registry.gd`, `resources/art/first_pass/derived/icons/mastery_fire.png`, `resources/art/first_pass/derived/vfx/`)
- A standalone Elemental Mastery HUD comparison scene exists for visual selection and records the five reference-driven variants: Reference Faithful, Combat Fit, Taller Mastery Section, Reduced Border Noise, and Feedback Ready. Variant 5 was selected for combat runtime on 2026-05-01. The preview uses generated reference-style panel/card chrome (`mastery_preview_panel_frame.png`, `mastery_preview_card_*.png`) with the real main-menu mastery icon assets (`mastery_fire.png`, `mastery_ice.png`, `mastery_earth.png`, `mastery_heart.png`, `mastery_armor.png`, `mastery_gold.png`) so the gallery avoids empty medallions, letter placeholders, generated placeholder icons, checkerboard, and full-card badge crops. (source: `scenes/ui/elemental_mastery_hud_variants.tscn`, `scripts/ui/elemental_mastery_hud_variants.gd`, `tools/asset_tools/generate_mastery_preview_chrome.py`, `resources/art/first_pass/derived/icons/mastery_fire.png`, `docs/tmp_elemental_mastery_visual_issues.md`)
- Combat player section cohesion pass added a framed vitals block, `HP current / max` bar label, conditional Slay the Spire-inspired armor badge (`BLOCK +N` shown only when armor > 0), and recessed silhouette empty-slot treatment for equipment/consumables. (source: `scenes/combat/combat_player.tscn`, `scripts/combat/combat_player_controller.gd`, `scripts/ui/player_loadout_hud.gd`)
- Floating combo feedback now includes resolved group details: orb type and matched orb count are rendered in the popup, popup text is tinted by orb color, and clear burst size grows a bit with larger match groups for clearer high-impact reads. (source: `scripts/combat/combat_player_controller.gd`)

## Important Files

- `scripts/board/board_state.gd` - board data model
- `scripts/combat/combat_state_machine.gd` - turn resolution
- `scripts/core/run_state.gd` - run sequencing
- `scripts/content/content_registry.gd` - content pack and pools
- `scripts/shop/shop_service.gd` - shop actions
- `scripts/run/player_progression_service.gd` - progression transitions
- `scripts/ui/player_loadout_hud.gd` - shared combat/shop loadout and mastery renderer
- `scripts/combat/combat_player_controller.gd` - player-facing combat UI
- `scripts/flow/shop_player.gd` - player-facing shop UI

## Open Questions

- Which remaining QA items should be considered done only after manual validation on desktop and mobile. (source: `docs/test_plan.md`)

## Related Pages

- [[architecture]]
- [[setup]]
- [[file-map]]
- [[known-issues]]
