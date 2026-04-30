# Temporary Combat Feedback Polish Todo

## Purpose

Track the current screenshot-driven combat feedback polish pass. This file is temporary and should be removed or archived after the pass is accepted.

## Status Legend

- `[ ]` Not started.
- `[~]` In progress.
- `[x]` Implemented and validated.
- `[!]` Blocked or needs follow-up.

## Tasks

- [x] Combo popup obstruction
  - Screenshot issue: `COMBO xN` text overlaps active orbs and blocks board readability.
  - Target behavior: combo text remains readable but does not cover the matched orb cluster.
  - Implementation: moved/clamped combo popup placement off-cluster and added dark translucent panel + stacked content in `scripts/combat/combat_player_controller.gd:2294-2367`.
  - Effort:
    1. Created temporary tracker before runtime edits and recorded the original source refs for this issue.
    2. Added off-cluster placement, board clamping, and readable backplate in `scripts/combat/combat_player_controller.gd:2294-2367`.
    3. Fixed MCP strict-warning issues in combo popup helper locals in `scripts/combat/combat_player_controller.gd:2300-2303,2312-2315`.
  - Validation notes: implemented UI-only adjustments; pending runtime screenshot pass.

- [x] Board clear overlay opacity
  - Screenshot issue: clear overlays wash out orb identity, especially fire/heart/earth.
  - Target behavior: clear feedback remains visible while orb identity stays readable.
  - Implementation: clear overlay intensity reduced via `match_flash_color` and `orb_clear` burst alpha in `scripts/board/board_view.gd:13`.
  - Effort:
    1. Preserved earlier polish change reducing clear overlay intensity in `scripts/board/board_view.gd:13`.
    2. Kept the change presentation-only; no resolver, combo, or combat math files were changed for this item.
  - Validation notes: pending runtime screenshot pass.

- [x] Enemy impact square/artifact
  - Screenshot issue: enemy impact appears as a square patch with unwanted markings over the portrait.
  - Target behavior: enemy/player impact uses clean replay impact assets and anchors to target body area.
  - Implementation: routed replay impacts through `_replay_turn_resolution_from_log()` -> `_spawn_replay_impact`/`_control_global_center`, and confirmed impact selection through `scripts/ui/visual_registry.gd:293`.
  - Effort:
    1. Preserved clean impact asset lookup through `scripts/ui/visual_registry.gd:293`.
    2. Centralized replay impact emission under `_replay_turn_resolution_from_log()` in `scripts/combat/combat_player_controller.gd:1618-1658`.
    3. Fixed strict-warning issues in replay impact helper code in `scripts/combat/combat_player_controller.gd:2124,2176-2179,2225`.
  - Validation notes: pending runtime screenshot pass.

- [x] Detached/clipped mastery beam
  - Screenshot issue: mastery beam appears detached in the right gutter instead of clearly connecting source and target.
  - Target behavior: beams connect from mastery card to enemy/player/gold target and stay inside relevant combat space.
  - Implementation: source now resolves via `_elemental_mastery_cards` (`scripts/combat/combat_player_controller.gd:76,2188-2197`), beam trigger path is centralized in `_replay_turn_resolution_from_log()` (`scripts/combat/combat_player_controller.gd:1618-1658`), and helper remains backward-compatible (`scripts/combat/combat_player_controller.gd:2230-2259`).
  - Effort:
    1. Aligned beam source ownership to active mastery cards via `_elemental_mastery_cards` in `scripts/combat/combat_player_controller.gd:76,2188-2197`.
    2. Centralized mastery beam replay path in `_replay_turn_resolution_from_log()` at `scripts/combat/combat_player_controller.gd:1618-1658`.
    3. Fixed parser typing regression in beam math locals with explicit `Vector2`/`float` types in `scripts/combat/combat_player_controller.gd:2256-2263`.
    4. Restored Elemental Mastery panel layout constants and `_apply_combat_mastery_panel_layout()` in `scripts/combat/combat_player_controller.gd:77-78,138-149,2454,2478,2561-2586`.
    5. Fixed runtime crash from invalid `Control.to_local()` calls by converting source/target globals with `_vfx_layer.get_global_transform_with_canvas().affine_inverse()` in `scripts/combat/combat_player_controller.gd:2264-2266`.
    6. Rebalanced the active mastery card row to fit six cards inside the panel and moved the title above the cards in `scripts/combat/combat_player_controller.gd:138-141` and `scripts/ui/player_loadout_hud.gd:15-17,189-214`.
    7. Wired `turn_log` values into transient card feedback labels and allowed elemental beams to fire from per-element values even when enemy block absorbs all HP damage in `scripts/combat/combat_player_controller.gd:1626-1708`.
  - Validation notes: pending runtime screenshot pass.

- [x] Duplicate locked timer text
  - Screenshot issue: timer strip shows duplicated `LOCK LOCK`.
  - Target behavior: locked state shows one clear lock label.
  - Current source references: `scripts/combat/combat_player_controller.gd:1486` (state set), `scripts/combat/combat_player_controller.gd:1487` (state hidden).
  - Implementation: set `_timer_label.text = "LOCK"` and `_timer_state_label.text = ""` in `scripts/combat/combat_player_controller.gd:1486-1487`.
  - Effort:
    1. Changed locked timer state to one visible label in `scripts/combat/combat_player_controller.gd:1486-1487`.
    2. Kept the hidden secondary timer-state label available for non-lock states without adding new UI nodes.
    3. Suppressed legacy bottom mastery strip while validating the same combat layout pass in `scripts/combat/combat_player_controller.gd:2105-2110,2111-2117,2544-2549`.
  - Validation notes: implemented.

- [x] Elemental mastery card sizing + replay feedback visibility
  - Screenshot issue: mastery strip appears as a shallow 2D strip; combat resolution feedback no longer appears meaningful.
  - Target behavior: panel/card row reads taller/denser, icon/title/level/`+N` are readable, and per-element turn values show briefly on the active cards after replay.
  - Implementation: updated `scripts/ui/player_loadout_hud.gd` card geometry constants + label positions, then mapped feedback values in
    `scripts/combat/combat_player_controller.gd::_replay_turn_resolution_from_log()` and `_play_combat_mastery_feedback_from_turn_log()` with short stagger and clear.
  - Effort:
    1. Added small timer-staggered feedback sequence so cards reveal in left-to-right-ish order (`COMBAT_MASTERY_FEEDBACK_STAGGER_SECONDS`) and clear afterwards in `scripts/combat/combat_player_controller.gd:1674-1708`.
    2. Triggered elemental beams from per-element values even when `enemy_damage_taken == 0` by using per-element checks in `scripts/combat/combat_player_controller.gd:1645-1658`.
    3. Kept player panel anchor region unchanged and reflowed only the board/mastery split in `scripts/combat/combat_player_controller.gd:138-142`.
    4. Corrected card overflow from `176px` to `164px` cards with `8px` gaps in `scripts/ui/player_loadout_hud.gd:15-17`.
    5. Corrected title/card and label/level/feedback overlaps in `scripts/combat/combat_player_controller.gd:140-141` and `scripts/ui/player_loadout_hud.gd:189-214`.
  - Validation notes:
    1. `git diff --check` passed.
    2. Godot MCP `play_scene` current scene passed and `get_godot_errors` reported `Session has no errors`.
    3. Godot MCP scene tree confirmed six `164x186` cards fit in `ElementalMasteryCards size=Vector2(1028,186)`.
    4. Manual drag/cascade visual acceptance remains pending.

## Effort Log

- Effort details are embedded under each task above so implementation history is visible next to the relevant screenshot issue.

## Validation Log

- 2026-04-30: `git diff --check` completed (no whitespace or syntax artifacts).
- 2026-04-30: `godot-mcp --version` unavailable from this shell (`term is not recognized`), so no MCP parse/load validation could be run from this environment.
- 2026-04-30: MCP parse failure observed (inference errors): `_spawn_mastery_beam` locals `source_local`, `target_local`, `delta`, `distance` at
  `scripts/combat/combat_player_controller.gd:2260-2263`.
- 2026-04-30: MCP parse issue fixed by explicit typing (`Vector2` and `float`) for the same locals in
  `scripts/combat/combat_player_controller.gd:2260-2263`.
- 2026-04-30: MCP parse failure observed (inference errors): `_spawn_combo_floating_text` locals `cell_span` and `blocked_radius` at
  `scripts/combat/combat_player_controller.gd:2320-2321`.
- 2026-04-30: MCP parse issue fixed by explicit `float` typing and `absf`/`maxf` for those locals in
  `scripts/combat/combat_player_controller.gd:2320-2321`.
- 2026-04-30: MCP strict-warning failure observed in new helper code: unused parameter, enum/integer-narrowing, and float-bound conversion warnings in
  `scripts/combat/combat_player_controller.gd:2124,2176-2179,2225,2300-2315`.
- 2026-04-30: MCP strict-warning fixes applied with explicit typing and float helpers in helper code:
  `scripts/combat/combat_player_controller.gd:2124`, `scripts/combat/combat_player_controller.gd:2176-2179`, `scripts/combat/combat_player_controller.gd:2225`,
  `scripts/combat/combat_player_controller.gd:2300-2303`, `scripts/combat/combat_player_controller.gd:2312-2315`.
- 2026-04-30: MCP runtime scene-tree blocker observed: `ElementalMasteryPanel` was `size=Vector2(2,2)` and `position=Vector2(0,0)` after layout pass.
- 2026-04-30: MCP layout regression fixed by restoring validated constants and adding `_apply_combat_mastery_panel_layout()` in
  `scripts/combat/combat_player_controller.gd`.
- 2026-04-30: MCP runtime scene-tree regression observed again in combat layout: old bottom `PlayerPanel/MasteryStrip` remained visible while `ElementalMasteryPanel` is active.
- 2026-04-30: MCP regression fixed by suppressing legacy strip display and population in `combat_player_controller.gd`:
  `scripts/combat/combat_player_controller.gd:2105-2110,2111-2117,2544-2549`.
- 2026-04-30: Final `git diff --check` pass completed with no output.
- 2026-04-30: Godot MCP load/instantiate probe passed with `ResourceLoader.CACHE_MODE_IGNORE` for changed scripts and
  `res://scenes/combat/combat_player.tscn`: controller, board, registry, scene, and instance all loaded.
- 2026-04-30: Godot MCP `play_scene` current scene passed and `get_godot_errors` reported `Session has no errors`.
- 2026-04-30: Godot MCP scene-tree inspection confirmed active combat layout:
  `BoardPanel size=Vector2(1048,734) position=Vector2(16,500)`,
  `ElementalMasteryPanel size=Vector2(1048,216) position=Vector2(16,1236)`,
  `ElementalMasteryCards size=Vector2(1028,176) position=Vector2(10,38)` with six cards,
  and `PlayerPanel/MasteryStrip visible=false`.
- 2026-04-30: Remaining validation gap: interactive screenshot acceptance after a real drag/cascade/enemy response is still pending.
  - 2026-04-30: Runtime crash reported by user: `Invalid call. Nonexistent function 'to_local' in base 'Control'` at
  `scripts/combat/combat_player_controller.gd:2264` during `_spawn_mastery_beam()`.
- 2026-04-30: Crash fix applied by replacing `Control.to_local()` usage with inverse canvas transform conversion in
  `scripts/combat/combat_player_controller.gd:2264-2266`.
- 2026-04-30: Post-fix `git diff --check` passed, `combat_player_controller.gd` opened in Godot editor without parse errors, and
  `ResourceLoader.CACHE_MODE_IGNORE` load/instantiate probe returned `controller=true scene=true instance=true`.
- 2026-04-30: Post-fix Godot MCP scene launch passed after clearing stale debugger output: `play_scene` current scene started and
  `get_godot_errors` reported `Session has no errors`.
  - 2026-04-30: Direct MCP force-call of `_spawn_mastery_beam()` on the running scene was not possible from the editor-script context
    because the running `CombatPlayer` node was not visible to that script (`combat=false`).
- 2026-04-30: Godot MCP validation for the current patch was attempted from a worker shell (`godot-mcp`), but CLI is unavailable there (`The term 'godot-mcp' is not recognized`).
- 2026-04-30: Follow-up regression reported by user: Elemental Mastery looked like a shallow strip and did not appear to do anything.
- 2026-04-30: Godot MCP scene-tree inspection caught an intermediate layout overflow: six `176px` cards plus gaps exceeded the `1028px`
  `ElementalMasteryCards` container, and the title overlapped the card row.
- 2026-04-30: Overflow/overlap fixed with `164x186` cards, `8px` gaps, cards rect `Vector2(10,40)/Vector2(1028,186)`,
  and non-overlapping card internals in `scripts/combat/combat_player_controller.gd:138-141` and
  `scripts/ui/player_loadout_hud.gd:15-17,189-214`.
- 2026-04-30: Post-fix Godot MCP validation passed: `play_scene` current scene started, `get_godot_errors` reported
  `Session has no errors`, `ElementalMasteryPanel size=Vector2(1048,232) position=Vector2(16,1220)`,
  `ElementalMasteryCards size=Vector2(1028,186) position=Vector2(10,40)`, and six `164x186` cards fit within the row.

## Cleanup Criteria

- Remove or archive this file after screenshot polish is accepted.
- Before cleanup, ensure durable behavior notes are reflected in `docs/test_plan.md`, `wiki/features.md`, and `wiki/log.md` if the changes remain in the project.
