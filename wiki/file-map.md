# File Map

**Summary**: High-level map of the important folders and files in the current Orbwalker checkout.

**Sources**: `project.godot`, `AGENTS.md`, `.codex/config.toml`, `.codex/agents/`, `todo.md`, `docs/system_architecture.md`, `docs/architecture_review_tasks.md`, `scenes/main.tscn`, `scenes/combat/board_debug.tscn`, `scenes/combat/combat_player.tscn`, `scenes/board/board_surface.tscn`, `scenes/flow/shop_player.tscn`, `scenes/flow/boss_relic_reward.tscn`, `scripts/core/run_state.gd`, `scripts/board/board_state.gd`, `scripts/board/board_surface.gd`, `scripts/combat/combat_state_machine.gd`, `scripts/content/content_registry.gd`, `scripts/run/player_progression_service.gd`, `scripts/shop/shop_service.gd`, `scripts/ui/player_loadout_hud.gd`, `scripts/debug/board_debug_controller.gd`, `scripts/debug/ar01_combat_result_probe.gd`, `resources/art/first_pass/`, `resources/content/`, `resources/visual/`

**Last updated**: 2026-05-03

---

## Overview

The repository is a Godot project with scenes, gameplay scripts, first-pass art, and content assets already separated into focused folders. (source: `project.godot`, repository layout)

## Details

- `scenes/` - Scene entry points and player-facing flow. Important files include `scenes/main.tscn`, `scenes/combat/board_debug.tscn`, `scenes/combat/combat_player.tscn`, reusable board surface `scenes/board/board_surface.tscn`, `scenes/flow/shop_player.tscn`, `scenes/flow/boss_relic_reward.tscn`, `scenes/ui/elemental_mastery_hud_variants.tscn`, and the placeholder run summary/shop scenes. The combat scene now contains explicit mobile HUD zones, a timer-only strip, a board-level outcome overlay that handles defeat in-place with a `Main Menu` button, and a connected `PlayerHudSection` that wraps `ElementalMasteryPanel` plus `PlayerPanel` with `HeroCard`, `VitalsPanel`, and `LoadoutFrame`; shop dynamically builds the same `PlayerHudSection` hierarchy above its shop controls. The UI variant scene is a standalone Elemental Mastery visual comparison gallery. (source: repository layout, `scripts/core/run_state.gd`, `scenes/combat/combat_player.tscn`, `scripts/flow/shop_player.gd`, `scenes/ui/elemental_mastery_hud_variants.tscn`)
- `scripts/core/` - Global run orchestration and shared startup logic. `run_state.gd` is the main autoload-backed controller, `main_boot.gd` handles the main menu launch, and `audio_manager.gd` owns music/SFX playback. Desktop/editor playback prefers exported WAV music over code-generated fallback loops. Android/template builds try non-imported raw WAV payload copies in `resources/audio/raw_music/` first, then imported music WAV resources, then generated fallback, so exported APK playback can keep full uploaded WAV byte length and loop timing. (source: `scripts/core/run_state.gd`, `scripts/core/main_boot.gd`, `scripts/core/audio_manager.gd`, `resources/audio/music/`, `resources/audio/raw_music/`)
- `scripts/board/` - Board model, generation settings, orb typing, match resolver, board rendering, and board surface wrapper script for scene composition reuse. (source: `scripts/board/board_state.gd`, `scripts/board/board_view.gd`, `scripts/board/board_surface.gd`)
- `scripts/combat/` - Combat state machine, player state, enemy state, and the combat scene controller. (source: `scripts/combat/combat_state_machine.gd`, `scripts/combat/combat_player_controller.gd`)
- `scripts/content/` - Content registry and validation. (source: `scripts/content/content_registry.gd`)
- `scripts/run/` - Player progression state and service. (source: `scripts/run/player_progression_state.gd`, `scripts/run/player_progression_service.gd`)
- `scripts/shop/` - Shop state and shop service. (source: `scripts/shop/shop_state.gd`, `scripts/shop/shop_service.gd`)
- `scripts/flow/` - Transition and flow controllers for shop, boss relic reward, and summary surfaces. Defeat summaries are now shown in the combat overlay; the legacy run summary surface remains available for non-defeat inactive-run summaries. (source: `scripts/flow/boss_relic_reward.gd`, `scripts/flow/shop_player.gd`, `scripts/flow/run_summary_placeholder.gd`, `scripts/flow/shop_placeholder.gd`)
- `scripts/debug/` - Debug controller, resolver test runner, and retained AR-01 combat result-envelope probe. The AR-01 probe is disabled by default behind `debug/ar01_combat_result_probe_enabled` and is intended for Godot MCP/editor-script regression capture before architecture refactors. (source: `scripts/debug/board_debug_controller.gd`, `scripts/debug/board_resolver_test_runner.gd`, `scripts/debug/ar01_combat_result_probe.gd`)
- `scripts/ui/` - Shared presentation helpers such as the visual registry, reusable connected player HUD/loadout/mastery renderer, and standalone Elemental Mastery HUD variant gallery script. `player_loadout_hud.gd` owns the shared combat/shop `PlayerHudSection` geometry, footer compatibility API, and optional layout override used by combat tall-portrait board scaling while shop keeps the default HUD rect. (source: `scripts/ui/visual_registry.gd`, `scripts/ui/player_loadout_hud.gd`, `scripts/ui/elemental_mastery_hud_variants.gd`)
- `tools/asset_tools/` - Utility scripts for asset extraction, cleanup, and deterministic first-pass art generation, including HUD slicing, derived icon alpha cleanup, menu chrome/icon alpha cleanup, character portrait placeholder generation, mastery reference panel/card/VFX generation, and Elemental Mastery preview panel/card chrome generation. (source: `tools/asset_tools/hud_extractor.gd`, `tools/asset_tools/clean_derived_icons.py`, `tools/asset_tools/clean_menu_art.py`, `tools/asset_tools/generate_character_placeholders.py`, `tools/asset_tools/generate_mastery_reference_assets.py`, `tools/asset_tools/generate_mastery_preview_chrome.py`)
- `resources/art/first_pass/` - First-pass backgrounds, enemy portraits, hero portraits, UI sheets, VFX, derived icons, Elemental Mastery preview frame/card chrome, derived mastery panel/card chrome, derived mastery beams/shell/impacts, and the `menu/` art package for the main menu background, logo, border, button plates, stat panel, and menu symbols. The preview scene and live combat variant-5 mastery panel use the existing real mastery icon assets for card badges, while the selected combat layout uses `mastery_preview_panel_frame.png` and `mastery_preview_card_*.png` as its panel/card chrome. Character portrait placeholders now include `heroes/hero_orbwalker.png` and enemy variants for `ruin_lancer`, `vault_executioner`, and `goldbound_keeper`. (source: repository layout, `resources/art/first_pass/menu/`, `resources/art/first_pass/heroes/`, `resources/art/first_pass/enemies/`, `resources/art/first_pass/derived/icons/mastery_fire.png`, `resources/art/first_pass/derived/ui_chrome/mastery_preview_panel_frame.png`, `resources/art/first_pass/derived/vfx/`)
- `resources/content/` - Content asset folders reserved for equipment, mastery, consumables, relics, boosters, enemies, bosses, and pricing. The current runtime content is still dictionary-backed, so these folders are not the primary source of truth yet. (source: `docs/system_architecture.md`, `scripts/content/content_registry.gd`)
- `resources/visual/` - First-pass visual asset map and theme resource. `resources/visual/first_pass_asset_map.json` includes main-menu art mappings plus complete runtime `enemy_portraits` and shared `hero_portraits` entries used by combat and shop portrait wiring. (source: repository layout, `resources/visual/first_pass_asset_map.json`)
- `resources/audio/music/` - Godot-ready WAV music rendered from MIDI sources for menu, combat, shop, credit, and melody candidates; runtime music loading uses these WAVs before generated fallback on desktop/editor and Android/template builds. (source: `resources/audio/music/`, `tools/audio/export_midi_to_wav.py`, `scripts/core/audio_manager.gd`)
- `resources/audio/raw_music/` - Non-imported byte-for-byte WAV payload copies (`*.wav.bin`) used by Android/template `AudioManager` loading to decode full uploaded WAV headers/data inside exported packages before falling back to imported resources. (source: `resources/audio/raw_music/`, `scripts/core/audio_manager.gd`)
- `raw/` - Raw source assets that are not edited by agents unless explicitly requested, currently including MIDI music sources, `GeneralUser GS v1.471.sf2` for music export, and `spash.png`, which is referenced by `project.godot` as the boot splash image. (source: `raw/`, `tools/audio/export_midi_to_wav.py`, `project.godot`)
- `tools/audio/` - Audio pipeline helpers, including the MIDI-to-WAV renderer that shells out to the local FluidSynth binary, uses the raw SoundFont, verifies WAV headers, and normalizes rendered PCM levels. (source: `tools/audio/export_midi_to_wav.py`)
- `docs/` - Human-facing design, architecture, QA docs, and architecture-maintenance tracking. `docs/architecture_review_tasks.md` tracks refactor-risk tasks, regression harness work, and current/future architecture alignment before Milestone 10 balance closure. (source: `docs/game_design_document.md`, `docs/system_architecture.md`, `docs/architecture_review_tasks.md`, `docs/test_plan.md`)
- `todo.md` - Milestone and scope tracker for prototype work. (source: `todo.md`)
- `AGENTS.md` - Operating rules for source/wiki precedence, development workflow, and the project-local multi-agent workflow. (source: `AGENTS.md`)
- `.codex/` - Project-local Codex configuration, including the default model setting and custom `default`, `explorer`, and `worker` agent definitions. (source: `.codex/config.toml`, `.codex/agents/default.toml`, `.codex/agents/explorer.toml`, `.codex/agents/worker.toml`)

## Important Files

- `project.godot` - project entry and autoload configuration
- `todo.md` - milestone scope and status tracker
- `scenes/main.tscn` - startup scene
- `scripts/core/run_state.gd` - central runtime controller
- `scripts/content/content_registry.gd` - content data source and validation
- `scripts/debug/ar01_combat_result_probe.gd` - feature-flagged AR-01 combat envelope regression probe
- `scripts/ui/player_loadout_hud.gd` - shared combat/shop connected player HUD, loadout, and mastery renderer

## Open Questions

- Whether the reserved `resources/content/` folders will become the long-term content source or remain staging areas. (needs verification)

## Related Pages

- [[setup]]
- [[architecture]]
- [[features]]
