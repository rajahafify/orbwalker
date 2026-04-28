# Wiki Log

Append-only history of wiki operations.

## [2026-04-28] ingest | Initial Project Ingestion

- Source: `AGENTS.md`, `project.godot`, `todo.md`, `docs/system_architecture.md`, `docs/test_plan.md`, `docs/game_design_document.md`, `scripts/core/run_state.gd`, `scripts/content/content_registry.gd`, `scripts/combat/combat_state_machine.gd`, `scripts/shop/shop_service.gd`, `scripts/run/player_progression_state.gd`, `scripts/run/player_progression_service.gd`, `scripts/board/board_state.gd`, `scripts/board/board_view.gd`, `scripts/flow/shop_player.gd`, `scripts/flow/boss_relic_reward.gd`, `scripts/core/main_boot.gd`, `scripts/debug/board_debug_controller.gd`
- Changed:
  - Created `wiki/index.md`
  - Created `wiki/log.md`
  - Created `wiki/setup.md`
  - Created `wiki/architecture.md`
  - Created `wiki/file-map.md`
  - Created `wiki/features.md`
  - Created `wiki/decisions.md`
  - Created `wiki/known-issues.md`
  - Created `wiki/open-questions.md`
  - Created `raw/`
- Notes:
  - The live code currently uses a dictionary-backed `ContentRegistry`, while `docs/system_architecture.md` still describes a planned Resource-based content model. That mismatch is recorded in the wiki.

## [2026-04-28] docs | Milestone 9 Combat UI Replication Plan

- Source: `todo.md`, `docs/test_plan.md`, `scenes/combat/combat_player.tscn`, `scripts/combat/combat_player_controller.gd`, `scripts/ui/visual_registry.gd`, `C:/Users/Home/Desktop/combat-ref.png`
- Changed:
  - Created `wiki/milestone-9-combat-ui-replication-plan.md`
  - Updated `wiki/index.md`
- Notes:
  - Plan captures approved constraints: close-match fidelity, combat-only scope, and no new mana system.

## [2026-04-28] code-change | Milestone 9 Combat HUD Close-Match Pass

- Source: `scenes/combat/combat_player.tscn`, `scripts/combat/combat_player_controller.gd`, `scripts/ui/visual_registry.gd`, `docs/test_plan.md`, `C:/Users/Home/Desktop/combat-ref.png`
- Changed:
  - Updated `scripts/combat/combat_player_controller.gd`
  - Updated `scenes/combat/combat_player.tscn`
  - Updated `wiki/features.md`
- Notes:
  - Implemented combat-only close-match UI pass using existing visual assets and runtime data bindings.
  - No new mana system was introduced; secondary blue bar remains presentation for existing armor flow.

## [2026-04-28] code-change | Combat Scene Reset To Board-Only Baseline

- Source: `scenes/combat/combat_player.tscn`, `scripts/combat/combat_board_only_controller.gd`
- Changed:
  - Created `scripts/combat/combat_board_only_controller.gd`
  - Replaced `scenes/combat/combat_player.tscn` with board-only scene structure
  - Updated `wiki/features.md`
- Notes:
  - Removed all combat HUD sections to start Milestone 9 HUD revamp from a clean baseline while preserving only the board surface.

## [2026-04-28] code-change | Restore Combat Functionality With Plain Visual Baseline

- Source: `scenes/combat/combat_player.tscn`, `scripts/combat/combat_player_controller.gd`
- Changed:
  - Restored full combat scene functionality wiring in `scenes/combat/combat_player.tscn`
  - Updated `scripts/combat/combat_player_controller.gd` to plain-visual mode (no background art, no enemy portrait, no intent badge texture)
  - Removed temporary `scripts/combat/combat_board_only_controller.gd`
  - Updated `wiki/features.md`
- Notes:
  - Keeps gameplay and HUD behavior intact while stripping most art-heavy presentation for rebuild.

## [2026-04-28] code-change | Orb Sprite Cleanup For Board Rendering

- Source: `scripts/ui/visual_registry.gd`
- Changed:
  - Updated orb extraction cleanup to keep only the primary connected orb component after checker-noise removal.
- Notes:
  - Reduced visual glitch fragments on non-earth orb sprites while keeping the same orb texture source pipeline.

## [2026-04-28] code-change | Extract Reusable Board Surface From Combat UI

- Source: `scenes/combat/combat_player.tscn`, `scenes/board/board_surface.tscn`, `scripts/combat/combat_player_controller.gd`, `scripts/board/board_surface.gd`
- Changed:
  - Created `scenes/board/board_surface.tscn`
  - Created `scripts/board/board_surface.gd`
  - Updated `scenes/combat/combat_player.tscn` to instance `BoardSurface`
  - Updated `scripts/combat/combat_player_controller.gd` to bind through `BoardSurface`
  - Updated `wiki/file-map.md`
- Notes:
  - Refactor keeps combat behavior intact while separating board composition from combat-specific scene layout.
