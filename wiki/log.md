# Wiki Log

Append-only history of wiki operations.

## [2026-05-03] code-change | Combat And Shop Item Popover Sell

- Source: `scripts/combat/combat_player_controller.gd`, `scripts/flow/shop_player.gd`, `docs/test_plan.md`, `wiki/features.md`
- Changed:
  - Added shop-style item description popovers to combat loadout slots using the shared `PlayerLoadoutHud` hover signals.
  - Added combat sell support for hovered equipment and consumable slots, allowing in-fight sell decisions.
  - Updated shop hover behavior so a filled equipment or consumable slot is selected by the same popover interaction, making the visible Sell action usable without a separate sell row.
- Validation:
  - Godot MCP `view_script` and `get_godot_errors` reported no session errors.
  - Active-run visual click-through remains useful to confirm final popover placement and input feel.

## [2026-05-03] code-change | Consumable Slot Use And Relic Offer Filtering

- Source: `scripts/combat/combat_player_controller.gd`, `scripts/shop/shop_service.gd`, `docs/test_plan.md`, `wiki/features.md`
- Changed:
  - Wired combat HUD consumable slot clicks to the existing consumable-use flow with the clicked slot index, while preserving the first-slot debug hotkey path.
  - Changed shop relic offer generation to filter out relics already owned by the player.
  - Invalidates a cached per-level relic offer if that relic is now owned before generating a replacement.
- Validation:
  - Godot MCP `view_script`, focused helper probes, and `get_godot_errors` reported no session errors.
  - Direct autoload editor-script probes returned `<null>` in this MCP session, so active-run manual click-through remains useful for final acceptance.

## [2026-05-03] code-change | Debug Skip Fight Command

- Source: `scripts/core/run_state.gd`, `scripts/combat/combat_player_controller.gd`, `scripts/debug/board_debug_controller.gd`, `docs/test_plan.md`, `wiki/features.md`
- Changed:
  - Added `RunState.skip_to_fight(level, fight)` for debug run-flow jumps.
  - Added `/skip <level> <fight>` to the combat and board-debug consoles; fight `1` and `2` target normal fights, while fight `3` targets the level boss.
  - Reinitializes combat state and board state after a successful skip so `/skip 3 3` lands on the level 3 boss fight.
- Validation:
  - Godot MCP `view_script`, `get_godot_errors`, `play_scene current` for `res://scenes/combat/board_debug.tscn`, and running scene-tree inspection passed.
  - Direct editor-script access to the running debug node was unavailable, so manual console-entry click-through remains useful.

## [2026-05-03] code-change | Victory Summary Page Polish

- Source: `scripts/flow/run_summary_placeholder.gd`, `docs/test_plan.md`, `wiki/features.md`
- Changed:
  - Reworked the final victory/run-summary page from a narrow placeholder card into a full-screen portrait summary surface.
  - Added menu-art background, dim scrim, wide gold-framed panel styling, six readable stat cards, equipment/relic sections, and large `Start New Run` / `Main Menu` actions.
- Validation:
  - Godot MCP `view_script`, scene instantiate, `play_scene current`, and running scene-tree inspection passed after the summary-page polish.
  - `get_godot_errors` reported no session runtime errors but retained a stale open-script diagnostic for the already-fixed `TextureRect` stretch enum.

## [2026-05-03] code-change | Boss Reward Modal Layering Fix

- Source: `scripts/combat/combat_player_controller.gd`, `docs/test_plan.md`, `wiki/features.md`, `wiki/known-issues.md`
- Changed:
  - Reparented the runtime outcome summary and new dim scrim under `CombatLayoutRoot` so boss reward choices layer above the connected player HUD.
  - Added a compact boss reward modal layout with three wider relic choice cards, dedicated relic image/text nodes, a separate `Skip Relic` action, and wrapped/truncated description text.
  - Changed relic claim and skip to advance directly to the shop instead of showing a post-selection confirmation card.
  - Changed final boss victory to skip boss relic selection and route directly to the victory summary.
  - Preserved the normal victory/defeat outcome card position by applying the old board-relative rect after reparenting.
- Notes:
  - Godot MCP `view_script` and `get_godot_errors` passed; previous overlay scene-tree inspection and `git diff --check` passed.
  - Manual end-to-end boss victory into relic choice into post-boss shop, plus final boss victory into run summary, remains useful for final visual acceptance.

## [2026-05-02] code-change | Defeat Overlay Run Summary

- Source: `scripts/combat/combat_player_controller.gd`, `scripts/core/run_state.gd`, `scripts/flow/run_summary_placeholder.gd`, `docs/test_plan.md`, `wiki/features.md`, `wiki/file-map.md`
- Changes:
  - Changed defeat flow to stay on the combat board-level outcome overlay and show a `Main Menu` button instead of continuing to a separate post-defeat summary screen.
  - Added defeat overlay summary copy for total gold earned, monsters killed, bosses killed, level reached, and defeat cause.
  - Added `bosses_defeated` tracking to `RunState` and kept the legacy run summary scene aligned with monster and boss counts.
- Validation:
  - Godot MCP script focus and `get_godot_errors` reported no script errors.
  - Godot MCP opened and played `res://scenes/combat/combat_player.tscn`; the running scene contains the resized hidden `OutcomeSummaryPanel` under `BoardPanel`.

## [2026-05-02] combat | Pooled Mastery Number Release

- Source: `scripts/combat/combat_player_controller.gd`, `docs/test_plan.md`, `wiki/features.md`
- Changed:
  - Changed Elemental Mastery numeric feedback to pool during match/combo ticks instead of replacing the previous card value.
  - Reapplied the pooled values after HUD refresh so they stay visible between cascade resolution and turn replay.
  - Released pooled mastery values one card at a time as post-cascade beam/impact effects fire.
  - Temporarily widened mastery replay beams and made them fully opaque for easier playtest visibility.
- Validation:
  - Godot MCP `view_script` and `get_godot_errors` reported no session errors after the controller edit.

## [2026-05-02] combat | Combo After Clear Timing

- Source: `scripts/combat/combat_player_controller.gd`, `docs/test_plan.md`, `wiki/features.md`
- Changed:
  - Moved combo/mastery presentation ticks to run after match flash, clear animation, and `clear_visual_commit`.
  - Kept combo/mastery before gravity and refill, matching the intended visible order: drag finish, match flash, clear animation, combo, mastery preview, gravity, refill.
  - Updated feature and QA notes that previously described combo ticks immediately after match flash.
- Validation:
  - Godot MCP `view_script` and `get_godot_errors` reported no session errors.
  - Godot MCP `play_scene` smoke for `res://scenes/combat/combat_player.tscn` started successfully and reported no session errors.
  - User manual acceptance confirmed the revised presentation order feels correct.

## [2026-05-02] combat | Delayed Visual Resolve Commits

- Source: `scripts/combat/combat_player_controller.gd`, `docs/test_plan.md`, `wiki/features.md`
- Changed:
  - Delayed visual board clone mutation for clear, gravity, and refill until after each matching BoardView animation duration completes.
  - Split the post-animation hold from the animation duration so cascade pacing stays the same while visual board state no longer jumps at animation start.
  - Renamed presentation trace points to `clear_visual_commit`, `gravity_visual_commit`, and `refill_visual_commit` to distinguish visible state mutation from resolver simulation signals.
- Validation:
  - Godot MCP `view_script` and `get_godot_errors` reported no session errors.
  - Godot MCP `play_scene` smoke for `res://scenes/combat/combat_player.tscn` started successfully and reported no session errors.
- Notes:
  - This keeps the hidden simulation resolver unchanged; only visible presentation replay timing changed.

## [2026-05-02] combat | Resolve Trace Console Output

- Source: `scripts/combat/combat_player_controller.gd`, `docs/test_plan.md`, `wiki/features.md`
- Changed:
  - Corrected resolve timing trace output from the in-game combat log to Godot console/output `print(...)` lines.
  - Kept the `[ResolveTrace +NNNNms]` phase format so `get_godot_errors` recent output logs can capture the same resolve timing sequence during runtime.
  - Restored combat log retention to 120 lines because resolve tracing no longer consumes in-game log history.
- Validation:
  - Godot MCP `view_script` and `get_godot_errors` reported no session errors.
  - Godot MCP `play_scene` smoke for `res://scenes/combat/combat_player.tscn` started successfully and reported no session errors.
- Notes:
  - This entry supersedes the previous `/log_level detailed` enablement note for resolve timing traces.

## [2026-05-02] combat | Resolve Trace Logging

- Source: `scripts/combat/combat_player_controller.gd`, `docs/test_plan.md`, `wiki/features.md`
- Changed:
  - Added detailed-only `[ResolveTrace +NNNNms]` combat log lines for post-drag resolve presentation debugging.
  - Logged drag release, visual/simulation board setup, resolver simulation signals, presentation pass starts, match flash, combo ticks, clear, gravity, refill, animation drain, final board commit, and combo/mastery preview amounts.
  - Increased retained combat log lines from 120 to 220 so a multi-pass cascade trace is less likely to push earlier phase lines out of the debug console.
- Validation:
  - Godot MCP `view_script` and `get_godot_errors` reported no session errors.
  - Godot MCP `play_scene` smoke for `res://scenes/combat/combat_player.tscn` started successfully; a narrowed running scene-tree query confirmed the combat hierarchy.
- Notes:
  - Enable with `/log_level detailed` before dragging; normal log level stays compact.

## [2026-05-02] combat | Explicit Combo Timing Phase

- Source: `scripts/combat/combat_player_controller.gd`, `docs/test_plan.md`, `wiki/features.md`
- Changed:
  - Changed match feedback to wait for the full scaled flash duration before combo feedback starts.
  - Added an explicit per-pass combo tick phase between match flash and clear animation.
  - Combo ticks now preserve resolver group order, update the single `COMBO xN` popup, trigger matching Elemental Mastery preview immediately, and hold before the next tick or clear.
  - Kept the previous visual/simulation board split, but this entry supersedes it as the fix for combo timing specifically.
- Validation:
  - Godot MCP `view_script` and `get_godot_errors` reported no session errors.
  - Godot MCP resolver tick-order probe confirmed simultaneous groups become sequential combo ticks across passes.
  - Godot MCP `play_scene` smoke for `res://scenes/combat/combat_player.tscn` started successfully; a narrowed running scene-tree query confirmed the combat hierarchy.
- Notes:
  - Manual feel acceptance is still needed for real drag/cascade timing.

## [2026-05-02] combat | Resolve Presentation State Split

- Source: `scripts/combat/combat_player_controller.gd`, `docs/test_plan.md`, `wiki/features.md`
- Changed:
  - Cleared active board animations at drag release before resolve presentation starts, preventing leftover swap overlays and suppressed cells from leaking into match clear/fall/refill.
  - Split post-drag board handling into a visual clone for `BoardView` presentation and a simulation clone for `BoardMatchResolverV3.resolve_all(...)`.
  - Committed the simulated final board back to `_board_state` only after visual clear, gravity, refill, and cascade replay completes.
  - Updated QA and feature notes for the new resolve presentation ownership model.
- Validation:
  - Godot MCP `view_script` and `get_godot_errors` reported no session errors.
  - Godot MCP deterministic replay probe returned `ok: true`, proving replayed visual mutations end at the same board as resolver simulation.
  - Godot MCP `play_scene` smoke for `res://scenes/combat/combat_player.tscn` started successfully; a narrowed running scene-tree query confirmed the combat hierarchy.
- Notes:
  - Manual feel acceptance is still needed for real drag/cascade timing.

## [2026-05-02] combat | Post-drag presentation speed

- Source: `scripts/combat/combat_player_controller.gd`, `docs/test_plan.md`, `wiki/features.md`
- Changed:
  - Added a hidden post-drag presentation speed setting with `slow`, `fast`, and `instant` options; `slow` is the default.
  - Slowed combo count updates, match flash/clear, gravity/refill, and turn replay sequencing so cascade counts and elemental beams are easier to observe.
  - Kept combo feedback to one updating `COMBO xN` popup and removed per-orb detail text from the popup.
  - Reframed visible match presentation as an explicit trigger chain: match feedback triggers the combo counter, and the combo counter update triggers the matching Elemental Mastery preview.
  - Kept a cloned pre-resolve board on screen during resolve animation so the first matched orbs flash and clear before refill orbs appear.
  - Added a one-frame render handoff after queuing match flash so the first combo counter cannot appear before the board flash is drawn.
- Validation:
  - `git diff --check` passed.
  - Godot MCP script check and `res://scenes/combat/combat_player.tscn` run/load check reported no errors.
  - Manual screenshot/feel acceptance is still pending.

## [2026-04-30] codex | Default Agent Model Updated

- Source: `.codex/config.toml`, `.codex/agents/default.toml`
- Changed:
  - Updated the project-local default Codex model to `gpt-5.5`
  - Set the default Codex reasoning effort to `low`
  - Updated the default agent instructions to match the new baseline
- Notes:
  - Explorer and worker role profiles were left unchanged.

## [2026-04-30] combat | Visible resolve burst polish

- Source: `scripts/combat/combat_player_controller.gd`, `scenes/combat/combat_player.tscn`
- Changed:
  - Enabled the combat `VfxLayer` at runtime so transient resolve effects render in the player-facing combat scene
  - Moved visible orb-clear bursts into the resolve animation pass next to combo floating text
  - Added combat resolver phase log lines for match found, clear, gravity, refill, cascade complete, and resolve complete states
- Notes:
  - This is a small post-drag polish step that makes the visible match clear feel punchier without touching combat math.

## [2026-04-30] code-change | Resolve Bubble Orb Detail And Burst Scaling

- Source: `scripts/combat/combat_player_controller.gd`
- Changed:
  - Updated floating combo popups in `_spawn_combo_floating_text()` to show `COMBO`, orb type, and matched orb count from resolver groups.
  - Tinted popup text with orb color instead of fixed gold styling.
  - Scaled clear burst size in `_spawn_group_resolve_burst()` based on group match size, preserving all existing resolve timing.
- Notes:
  - This is a UI feedback polish pass; combat math and resolver sequencing were not modified.

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

## [2026-04-28] code-change | Portrait Mobile Viewport And Combat HUD Layout Pass

- Source: `project.godot`, `scenes/combat/combat_player.tscn`, `scripts/combat/combat_player_controller.gd`, `C:/Users/Home/Desktop/combat-ref.png`
- Changed:
  - Updated `project.godot` to portrait viewport `1080x1920`
  - Updated `scenes/combat/combat_player.tscn` to show combat HUD sections by default and tune panel sizing/margins
  - Updated `scripts/combat/combat_player_controller.gd` responsive breakpoints and portrait sizing targets
  - Updated `wiki/features.md`
- Notes:
  - This pass focuses on matching overall mobile composition from the provided reference while keeping current runtime bindings and placeholder visuals.

## [2026-04-28] code-change | Combat HUD Visual Polish Pass

- Source: `scenes/combat/combat_player.tscn`, `scripts/combat/combat_player_controller.gd`, `C:/Users/Home/Desktop/combat-ref.png`
- Changed:
  - Updated `scripts/combat/combat_player_controller.gd` for stronger panel/bar/button styling and typography hierarchy
  - Updated `scenes/combat/combat_player.tscn` section sizing and spacing for improved portrait composition
  - Updated `wiki/features.md`
- Notes:
  - Kept gameplay logic and data bindings unchanged; this pass is presentation-only polish for readability and reference alignment.

## [2026-04-28] code-change | Zone Refactor And Placeholder Blocks For Missing Combat Art

- Source: `scenes/combat/combat_player.tscn`, `scripts/combat/combat_player_controller.gd`, `C:/Users/Home/Desktop/combat-ref.png`
- Changed:
  - Updated `scenes/combat/combat_player.tscn` to tighten section spacing and make `BoardArea` explicit for zone sizing
  - Updated `scripts/combat/combat_player_controller.gd` with centralized zone-height profile (`_apply_zone_profile`)
  - Added persistent placeholder textures for missing intent/enemy/hero art slots
  - Updated `wiki/features.md`
- Notes:
  - Refactor is aimed at faster visual iteration and clearer zone-by-zone tuning without touching combat logic.

## [2026-04-28] code-change | Promote Combat Zones To First-Class Scene Nodes

- Source: `scenes/combat/combat_player.tscn`, `scripts/combat/combat_player_controller.gd`
- Changed:
  - Renamed and normalized major sections to explicit zone nodes: `TopBar`, `EnemyPanel`, `CombatStrip`, `BoardPanel`, `PlayerPanel`
  - Updated controller bindings and style/size logic to target the new zone names
  - Updated `wiki/features.md`
- Notes:
  - This is a structural readability refactor for faster polish iteration; no combat behavior changes.

## [2026-04-28] code-change | Full Zone Polish Refactor With Placeholders And Guides

- Source: `scenes/combat/combat_player.tscn`, `scripts/combat/combat_player_controller.gd`, `C:/Users/Home/Desktop/combat-ref.png`
- Changed:
  - Tightened major zone spacing and heights to reduce dead space (`EnemyPanel`, `CombatStrip`, `BoardPanel`, `PlayerPanel`)
  - Refactored player internals into explicit subzones: `PlayerStatsRow`, `CombatMetaRow`, `LoadoutRow`
  - Added stable placeholders for missing intent/enemy/hero visuals with preserved layout footprint
  - Added toggleable zone guide labels/outlines on `F2` for polish iteration
  - Updated `wiki/features.md`
- Notes:
  - Focused on presentation architecture and polish workflow; core combat logic remains unchanged.

## [2026-04-28] code-change | Final Mobile Combat Polish Consolidation

- Source: `scenes/combat/combat_player.tscn`, `scripts/combat/combat_player_controller.gd`, `C:/Users/Home/Desktop/combat-ref.png`
- Changed:
  - Reduced remaining dead space and rebalanced zone proportions for mobile portrait
  - Consolidated layout/typography tuning into shared controller constants
  - Stabilized combo block width and right alignment in combat strip
  - Simplified player metadata line formatting and constrained summary verbosity
  - Kept placeholder-driven enemy/intent/hero footprints active for continued artless polish
  - Updated `wiki/features.md`
- Notes:
  - Intended as a full implementation of the requested polish checklist while keeping gameplay behavior unchanged.

## [2026-04-29] code-change | Combat Screen Design-Space Layout Rebuild

- Source: `scenes/combat/combat_player.tscn`, `scripts/combat/combat_player_controller.gd`, `C:/Users/Home/Desktop/combat-ref.png`
- Changed:
  - Replaced vertical combat HUD layout with `CombatLayoutRoot` and direct design-space rect positioning
  - Added `_apply_combat_layout()` for scaled `1080x1920` zone placement
  - Rebuilt enemy, combat strip, board, and player panel composition around explicit subzones
  - Added generated placeholder helper methods for intent, enemy, and hero art footprints
  - Updated `wiki/features.md`
- Notes:
  - Validated scene instantiation and current-scene runtime through Godot MCP with no reported runtime errors.

## [2026-04-29] code-change | Timer-Only Strip And Loadout Group Polish

- Source: `scenes/combat/combat_player.tscn`, `scripts/combat/combat_player_controller.gd`, `C:/Users/Home/Desktop/combat-ref.png`
- Changed:
  - Removed combat strip combo/damage label and rebuilt timer lane with `TimerBadgePanel` icon+value plus single timer bar
  - Added timer placeholder generation and timer badge styling in combat controller
  - Rebuilt player loadout to centered framed groups: `EquipmentGroup` (5 slots) and `ConsumableGroup` (3 slots)
  - Updated slot rendering to 64px with darker empty placeholders and consumable count overlays
  - Updated `wiki/features.md` and `wiki/file-map.md`
- Notes:
  - Runtime validated via Godot MCP (`open_scene`, `play_scene`, `get_running_scene_screenshot`, `get_godot_errors`) with no active runtime errors.

## [2026-04-29] code-change | Combat Timer Urgency Readability Revamp

- Source: `scripts/combat/combat_player_controller.gd`, `scenes/combat/combat_player.tscn`
- Changed:
  - Updated timer formatting to show whole seconds in normal state and tenth-second precision during final warning window
  - Added timer urgency color states (`safe`, `warning`, `critical`) and applied them to both timer label and timer bar fill
  - Added critical low-time pulse behavior for better timeout visibility during drag
  - Updated `wiki/features.md`
- Notes:
  - Timer duration and move-end rules remain unchanged; this pass is readability and urgency signaling only.

## [2026-04-29] code-change | Combat Strip Timer Centering Fix

- Source: `scripts/combat/combat_player_controller.gd`
- Changed:
  - Centered the timer strip based on actual content width (`TimerBadgePanel + separator + MoveTimerBar`) instead of left-inset anchoring
  - Added responsive timer-bar width clamp so centering stays stable across viewport sizes
- Notes:
  - No timer logic changes; this is layout-only.

## [2026-04-29] code-change | Unified Combat Timer Track Revamp

- Source: `scenes/combat/combat_player.tscn`, `scripts/combat/combat_player_controller.gd`
- Changed:
  - Replaced the separate timer badge and progress bar with one centered `TimerTrack` control
  - Added track fill, overlay icon/value/state labels, and unified timer display syncing
  - Kept the 5 second movement timer, release behavior, and timeout behavior unchanged
  - Updated `wiki/features.md`
- Notes:
  - This replaces the previous centering workaround with a single fixed design-space timer slab.

## [2026-04-29] code-change | Timer Label Readability Fix

- Source: `scripts/combat/combat_player_controller.gd`
- Changed:
  - Separated timer foreground colors from timer fill colors for higher contrast
  - Added label outline and shadow styling to timer value and state labels
- Notes:
  - No timer logic or layout changes.

## [2026-04-29] code-change | Reference Player Panel Revamp

- Source: `scenes/combat/combat_player.tscn`, `scripts/combat/combat_player_controller.gd`, `C:/Users/Home/Desktop/combat-ref.png`
- Changed:
  - Rebuilt the combat player panel around reference-style bottom HUD zones: hero card, HP/armor vitals, stat chips, compact loadout rail, and mastery strip
  - Replaced large equipment/consumable boxes with fixed manual slot rails for 5 equipment and 3 consumables
  - Added equipment value badges, consumable count badges, dim empty-slot placeholders, and always-visible mastery levels
  - Updated `docs/test_plan.md`, `wiki/features.md`, and `wiki/file-map.md`
- Notes:
  - Godot MCP load/instantiate and running scene-tree checks passed for the new player-panel node structure and current portrait layout bounds.

## [2026-04-29] code-change | Compact Player Panel Cleanup

- Source: `scripts/combat/combat_player_controller.gd`, `docs/test_plan.md`, `wiki/features.md`
- Changed:
  - Hid the cramped armor bar, stat chip row, and turn summary text from the compact combat player panel
  - Moved the equipment/consumable rail and mastery strip upward with larger vertical spacing
  - Updated documentation to record the simplified compact player-panel presentation
- Notes:
  - Godot MCP runtime scene-tree inspection confirmed the cleaned player panel sections are visible and bounded in the current design-space layout.

## [2026-04-29] code-change | Player Panel Spacing Tightening

- Source: `scripts/combat/combat_player_controller.gd`, `docs/test_plan.md`
- Changed:
  - Reduced the hero card and portrait footprint
  - Pulled the equipment/consumable rail closer to the HP row
  - Compressed the mastery strip to remove unused vertical space
- Notes:
  - Godot MCP runtime scene-tree inspection confirmed the tightened player panel layout positions and bounds.

## [2026-04-29] code-change | Player Panel Frame Collapse

- Source: `scripts/combat/combat_player_controller.gd`, `scenes/combat/combat_player.tscn`, `docs/test_plan.md`, `todo.md`, `wiki/features.md`
- Changed:
  - Shortened the active player panel frame to the compact HUD content height
  - Kept the hero, HP, loadout, and mastery rows in fixed design-space positions
  - Converted `MasteryStrip` from `PanelContainer` to `Panel` so the compact mastery frame does not expand from child minimum sizing
  - Grouped mastery icons beside the `MASTERY` label and kept hidden legacy rows out of the visible panel
- Notes:
  - Godot MCP play-scene, runtime scene-tree, and error-log checks passed for the compact player panel bounds.

## [2026-04-29] code-change | Player Panel Reference Correction

- Source: `scripts/combat/combat_player_controller.gd`, `docs/test_plan.md`, `todo.md`, `wiki/features.md`
- Changed:
  - Restored the reference bottom-HUD proportions after the previous compact pass diverged too far
  - Enlarged the hero portrait card while keeping only the primary HP bar visible
  - Moved the equipment/consumable rail under the vitals block with larger slots and restored a full-width bottom mastery strip
  - Changed mastery entries from overlaid badges to icon-plus-number cells matching the reference row structure
  - Kept armor, stat chips, combat meta, and turn summary hidden so empty placeholder rows do not appear
- Notes:
  - Godot MCP play-scene, runtime scene-tree, and error-log checks passed with the corrected player-panel geometry.

## [2026-04-29] docs | Combat Player UI Redesign Brief

- Source: `docs/combat-player-ui.md`, user-provided combat screen screenshot
- Changed:
  - Created `docs/combat-player-ui.md`
  - Documented player-section visual problems and a design-focused fix for each issue
  - Added layout proportions, visual treatment guidance, phased implementation direction, and acceptance criteria
- Notes:
  - This is a design/implementation brief only; no runtime UI changes were made.

## [2026-04-29] code-change | Combat Player Section Cohesion Fix Pass

- Source: `scenes/combat/combat_player.tscn`, `scripts/combat/combat_player_controller.gd`, `docs/test_plan.md`, `wiki/features.md`
- Changed:
  - Added `VitalsFrame`, `ArmorBadge`, and `ArmorBadgeLabel` nodes under the combat player `VitalsPanel`
  - Rebalanced player panel layout rects to a clearer three-layer composition (`hero status`, `loadout`, `mastery`)
  - Updated HP presentation to `HP current / max` and added conditional Slay the Spire-inspired `BLOCK +N` armor badge visibility
  - Reworked empty equipment/consumable slot visuals to recessed silhouettes
  - Updated mastery cells to `icon + Lv N` labeling for non-debug readability
  - Updated `docs/test_plan.md` and `wiki/features.md` with verification notes and final behavior summary
- Notes:
  - Godot MCP `play_scene` and running scene-tree inspection confirmed player-panel node wiring and bounds in `res://scenes/combat/combat_player.tscn`.
  - Manual visual overlap/readability checks across target desktop/mobile aspect ratios remain required.

## [2026-04-29] code-change | Player HUD Level Badge Removal And Padding Tightening

- Source: `scripts/combat/combat_player_controller.gd`, `wiki/features.md`
- Changed:
  - Removed visible player-HUD level treatment by disabling `HeroLevelBadge` usage in runtime styling and layout flow
  - Tightened player-section spacing by moving loadout/mastery blocks upward and reducing internal loadout frame padding
  - Reduced top padding inside equipment/consumable rails and section labels for denser, cleaner vertical rhythm
  - Updated feature documentation to reflect that the level badge is no longer part of the visible player panel
- Notes:
  - This pass is UI-only and preserves existing combat/runtime data behavior.

## [2026-04-29] code-change | Player HUD Full-Width And Mastery Token Rebuild

- Source: `scripts/combat/combat_player_controller.gd`, `wiki/features.md`
- Changed:
  - Expanded player HUD bounds to full design width and rebalanced top-row geometry for cleaner portrait-to-vitals alignment
  - Kept a clear vertical gap between top status row and loadout row by separating row bounds with explicit spacing
  - Rebuilt mastery entries as fixed token cells with centered `icon + numeric value` (removed `Lv` wording)
  - Tuned mastery strip sizing and icon-row spacing to avoid cramped labels and overflow
- Notes:
  - This pass is visual/UI-only and does not change combat, progression, or content logic.

## [2026-04-29] code-change | Player HUD Reference Layout Correction

- Source: `scripts/combat/combat_player_controller.gd`, `scenes/combat/combat_player.tscn`
- Changed:
  - Kept the player HUD full-width while restoring the top row to a taller portrait/status block
  - Moved the loadout row down to create a real margin below the top row
  - Rebuilt mastery as one fixed-position strip of icon/value pairs instead of boxed `Lv` cells or nested container cards
  - Converted `MasteryRoot` and `MasteryIcons` to plain `Control` nodes so the row no longer expands from container minimum sizing
- Notes:
  - Godot MCP script parse and running scene-tree checks passed for the corrected player panel and mastery strip bounds.

## [2026-04-29] code-change | Player HUD Bottom Stick And Loadout Padding

- Source: `scripts/combat/combat_player_controller.gd`
- Changed:
  - Moved the player HUD to the bottom edge of the 1080x1920 design space by setting `PlayerPanel` to `y=1452` with height `468`
  - Increased `LoadoutFrame` height to add lower padding below the equipment and consumable slots
  - Moved `MasteryStrip` down to preserve spacing after the loadout padding increase
- Notes:
  - Godot MCP parse, scene load, play-scene, and running scene-tree checks passed; runtime bounds confirmed the player HUD bottom is exactly `1920`.

## [2026-04-29] code-change | Player HUD Padding Refinement

- Source: `scripts/combat/combat_player_controller.gd`
- Changed:
  - Increased loadout frame height and inset the equipment/consumable slot rails to add clearer internal padding
  - Moved mastery lower while preserving an explicit bottom gutter inside the sticky player HUD
  - Kept the portrait content inset within the hero card instead of reintroducing the hidden level badge
- Notes:
  - Godot MCP parse and refreshed running scene-tree checks confirmed the updated player-panel, loadout, mastery, and portrait bounds.

## [2026-04-29] code-change | Board Outcome Summary And Next Button Move

- Source: `scenes/combat/combat_player.tscn`, `scripts/combat/combat_player_controller.gd`, `wiki/features.md`
- Changed:
  - Moved `NextButton` from the player HUD into a new hidden board-level `OutcomeSummaryPanel`
  - Added `BoardShadow` behind `BoardSurface` and lowered the board to make room for the summary panel above it
  - Rewired victory/debug-victory flow to show the board outcome summary with the continue button, while player HUD stays focused on player status/loadout/mastery
  - Updated feature documentation for the board outcome overlay behavior
- Notes:
  - Godot MCP parse, scene load, play-scene, and board subtree inspection passed; manual visual review of the visible victory summary remains useful.

## [2026-04-29] code-change | Centered Victory Outcome Card

- Source: `scenes/combat/combat_player.tscn`, `scripts/combat/combat_player_controller.gd`, `wiki/features.md`
- Changed:
  - Enlarged and centered the board-level `OutcomeSummaryPanel` so victory reads as a modal card instead of a cramped banner
  - Updated victory summary copy to show `Victory` and `GOLD GAINED +N`
  - Renamed the outcome action button from `Next` to `Continue`
  - Centered the outcome title, gold summary, and button within the card
- Notes:
  - This is a UI-only polish pass for victory outcome presentation.

## [2026-04-29] code-change | Larger Combat Debug Overlay Text

- Source: `scenes/combat/combat_player.tscn`, `scripts/combat/combat_player_controller.gd`, `wiki/features.md`
- Changed:
  - Added explicit debug overlay font sizing for status text, enemy debug text, combat log text, and command input
  - Increased the console input minimum height to make the command area at least 1.5x larger
  - Increased debug overlay internal spacing to match the larger typography
  - Updated feature documentation for the debug overlay readability pass
- Notes:
  - This is a UI-only debug readability change.

## [2026-04-29] code-change | Double Combat Debug Overlay Font Size

- Source: `scenes/combat/combat_player.tscn`, `scripts/combat/combat_player_controller.gd`
- Changed:
  - Doubled combat debug overlay font constants from 18px to 36px
  - Increased debug console input minimum height from 54px to 96px
- Notes:
  - This is a UI-only adjustment after visual review showed the previous debug text was still too small.

## [2026-04-29] code-change | Tune Combat Debug Overlay Font Size

- Source: `scenes/combat/combat_player.tscn`, `scripts/combat/combat_player_controller.gd`
- Changed:
  - Adjusted combat debug overlay font constants from 36px down to 24px
  - Adjusted debug console input minimum height from 96px down to 72px
- Notes:
  - This is a UI-only tuning pass after 36px proved too large.

## [2026-04-29] code-change | Shop UI Revamp

- Source: `scenes/flow/shop_player.tscn`, `scripts/flow/shop_player.gd`, `scripts/ui/visual_registry.gd`, `wiki/features.md`
- Changed:
  - Rebuilt the shop scene around a portrait merchant layout root with explicit runtime zones for top bar, merchant stage, stock cards, relic card, actions, build panel, mastery strip, and booster overlay
  - Replaced the old text-list offers and sell `SpinBox` with card-based buying, selectable equipment sell slots, and large primary action buttons
  - Added a stable booster icon placeholder path in `VisualRegistry` so missing booster art does not trigger repeated fallback warnings
  - Updated `wiki/features.md` for the player-facing shop UI structure
- Notes:
  - This is a presentation and interaction polish pass; shop economy and service mechanics remain unchanged.

## [2026-04-29] code-change | Shared Player Loadout HUD

- Source: `scripts/ui/player_loadout_hud.gd`, `scripts/combat/combat_player_controller.gd`, `scripts/flow/shop_player.gd`, `wiki/features.md`, `wiki/file-map.md`
- Changed:
  - Extracted combat loadout/mastery rendering into reusable `PlayerLoadoutHud`
  - Rewired combat and shop to render equipment slots, consumable slots, relic icons, mastery cells, empty silhouettes, and slot badges through the shared helper
  - Kept shop-specific selling behavior by using the helper's selectable equipment-slot signal
  - Updated wiki feature and file-map documentation for the shared UI helper
- Notes:
  - Godot MCP script reload and scene instantiate checks passed for combat and shop; combat runtime smoke confirmed shared loadout/mastery nodes in the running scene.

## [2026-04-29] code-change | Combat-Style Shop Player HUD

- Source: `scripts/ui/player_loadout_hud.gd`, `scripts/combat/combat_player_controller.gd`, `scripts/flow/shop_player.gd`, `wiki/features.md`
- Changed:
  - Moved combat player-panel geometry into `PlayerLoadoutHud.apply_combat_player_panel_layout`
  - Updated combat to call the shared layout helper for its player HUD geometry
  - Replaced the shop-only build panel and separate mastery strip with a `PlayerPanel` using combat HUD subzones: `HeroCard`, `VitalsPanel`, `LoadoutFrame`, and `MasteryStrip`
  - Kept shop-specific gold badge and selectable equipment slots inside the shared combat-style HUD structure
- Notes:
  - Godot MCP script reload, shop/combat scene instantiation, combat runtime HUD tree, and shop no-active-run runtime checks passed.

## [2026-04-29] code-change | Post-Drag Result Overlay Sequence

- Source: `scenes/combat/combat_player.tscn`, `scripts/combat/combat_player_controller.gd`, `wiki/features.md`
- Changed:
  - Added board-level top and bottom edge overlay cards under `BoardPanel` for post-drag combat feedback
  - Added combo-first display right after drag resolve starts, then step-sequenced post-turn cards for damage calculator formulas, player effects, and enemy block/intent effects
  - Reused existing turn-log fields from `CombatStateMachine.resolve_player_turn()` to format player-facing substituted formulas and effect summaries without changing combat math
  - Kept victory/defeat on the existing centered outcome panel and ensured post-drag overlays hide before outcome flow
  - Updated feature documentation with the new post-drag overlay behavior
- Notes:
  - Godot MCP scene load/instantiate checks passed and runtime error checks reported no session errors.

## [2026-04-29] code-change | Combo Floating Text Pivot

- Source: `scripts/combat/combat_player_controller.gd`, `scenes/combat/combat_player.tscn`, `wiki/features.md`
- Changed:
  - Removed the post-drag edge-card result sequence and its damage/effect calculator presentation path
  - Added floating `COMBO xN` text popups on board-space near each matched resolver group via `_on_resolver_match_found`
  - Implemented pop + rise + fade combo text animation directly in the existing `VfxLayer` so combo feedback appears close to match locations during cascades
  - Cleaned now-unused post-drag scene nodes from `combat_player.tscn`
  - Updated feature documentation to describe the combo-floating behavior
- Notes:
  - Godot MCP load/instantiate checks passed for `res://scenes/combat/combat_player.tscn`.
  - Current runtime warnings are existing `VisualRegistry` fallback icon warnings, not parse/runtime script errors from this change.

## [2026-04-29] code-change | Cascade Combo Popup Timing Fix

- Source: `scripts/combat/combat_player_controller.gd`, `wiki/features.md`
- Changed:
  - Moved combo popup emission from resolver `match_found` callback timing to per-pass timing inside `_play_resolve_animations`
  - Kept combo counter progression (`x1`, `x2`, ...) but now increments and renders in the same order as visible cascade passes
  - Updated feature note to reflect per-pass animation-loop emission
- Notes:
  - Fix targets visibility timing only; combat resolution math is unchanged.

## [2026-04-29] code-change | Equipment Mastery Relic Asset Polish Pass

- Source: `tools/asset_tools/clean_derived_icons.py`, `resources/art/first_pass/derived/icons/`, `scripts/ui/player_loadout_hud.gd`, `scripts/combat/combat_player_controller.gd`, `scripts/flow/shop_player.gd`, `scripts/flow/boss_relic_reward.gd`
- Changed:
  - Created `tools/asset_tools/clean_derived_icons.py` to strip checkerboard backgrounds, restore icon alpha, and normalize derived icon canvas sizing
  - Reprocessed derived icon assets used by equipment, mastery, relics, and shared item card paths under `resources/art/first_pass/derived/icons/`
  - Added compact owned-relic rendering with overflow handling in `PlayerLoadoutHud` and rewired combat/shop to use it
  - Kept combat relic visibility for compact layouts (still hidden for low-vertical layouts) and exposed owned relics in the shop footer
  - Upgraded boss relic reward option buttons to visual card presentation with icon, rarity tint, and description text
  - Updated `wiki/features.md`, `wiki/file-map.md`, and `docs/test_plan.md`
- Notes:
  - Gameplay logic, pricing, progression math, and content IDs were unchanged.
  - Godot MCP verification remains pending in this thread because MCP tools were not exposed.

## [2026-04-29] docs | Rename Project to Orbwalker

- Source: `project.godot`, `scenes/main.tscn`, `docs/game_design_document.md`, `docs/system_architecture.md`, `docs/test_plan.md`, `todo.md`
- Changed:
  - Renamed the Godot project to `Orbwalker`
  - Updated the main menu title and start button copy to match the new game name
  - Renamed the active design, architecture, QA, todo, and wiki titles to `Orbwalker`
- Notes:
  - Historical log entries were left unchanged.

## [2026-04-29] docs | Main Menu Art Package

- Source: `resources/art/first_pass/menu/`, `resources/visual/first_pass_asset_map.json`, `wiki/main-menu-assets.md`, `wiki/index.md`, `wiki/file-map.md`, `wiki/features.md`
- Changed:
  - Added the generated main menu art package under `resources/art/first_pass/menu/`
  - Extended `resources/visual/first_pass_asset_map.json` with a `menu` mapping block for the background, logo, border, button plates, stat panel, menu icons, and reused mastery icons
  - Created `wiki/main-menu-assets.md` to document the generated assets and reuse rules
  - Updated `wiki/index.md`, `wiki/file-map.md`, and `wiki/features.md` to point at the new menu art package
- Notes:
  - The main menu scene still needs runtime wiring before the new art is used in-game.

## [2026-04-29] docs | Main Menu HTML Layout Guide

- Source: `docs/main_menu_layout_guide.html`, `wiki/main-menu-assets.md`
- Changed:
  - Added `docs/main_menu_layout_guide.html` with a 9:16 overlay mock, zone boundaries, safe area, and asset slot table for menu implementation planning
  - Updated `wiki/main-menu-assets.md` sources and important files to include the HTML guide
- Notes:
  - This guide is documentation-only; runtime scene wiring is still pending.

## [2026-04-29] docs | Main Menu HTML Recreation Prototype

- Source: `docs/main_menu_recreation.html`, `wiki/main-menu-assets.md`
- Changed:
  - Added `docs/main_menu_recreation.html` to visually recreate the reference main menu using the generated menu art pack and reused mastery icons
  - Updated `wiki/main-menu-assets.md` to include the HTML recreation artifact
- Notes:
  - This is an HTML prototype for visual matching; it does not change Godot runtime scene behavior.

## [2026-04-30] docs | Main Menu HTML Prototype Correction Pass

- Source: `docs/main_menu_recreation.html`, `resources/art/first_pass/menu/main_menu_logo_orbwalker_v1_alpha.png`, `resources/visual/first_pass_asset_map.json`, `wiki/main-menu-assets.md`
- Changed:
  - Corrected the HTML recreation composition with fixed section coordinates and tuned typography/spacing for closer visual parity with the reference menu
  - Created `main_menu_logo_orbwalker_v1_alpha.png` and switched the HTML logo usage to the transparent variant
  - Updated the menu asset map `menu.logo` entry to the alpha logo path
  - Updated `wiki/main-menu-assets.md` with alpha logo documentation and revised update date
- Notes:
  - The main issue reported in the screenshot was the non-transparent logo background and oversized section layout in the first HTML pass.

## [2026-04-30] code-change | Main Menu Runtime Scene Implementation

- Source: `scenes/main.tscn`, `scripts/core/main_boot.gd`, `docs/test_plan.md`, `wiki/main-menu-assets.md`, `wiki/features.md`
- Changed:
  - Replaced the prototype center-panel menu in `scenes/main.tscn` with an authored portrait main-menu scene tree containing explicit zones: `BackgroundTexture`, `OuterFrame`, `LogoTexture`, `MenuButtonColumn`, `ElementRow`, `StatsPanel`, `FooterActions`, `DebugCombatButton`, `VersionLabel`, and `StatusLabel`
  - Reworked `scripts/core/main_boot.gd` to load mapped background/logo assets, apply fixed design-space coordinate layout against the viewport, style runtime chrome with `StyleBoxFlat`, and keep `Start Run` plus `Debug Combat` as the only functional actions
  - Kept `Continue`, `Collection`, `Settings`, `Quit`, `Profile`, and `Achievements` visible as disabled placeholders
  - Updated test and wiki documentation to mark the scene as wired and capture remaining manual QA requirements
- Notes:
  - Generated menu border/button/stat-panel PNG chrome remains staged assets and is not used for runtime UI chrome in this pass.
  - Godot MCP validation is still pending in this session because MCP tools were not exposed.

## [2026-04-30] code-change | Main Menu MCP Validation And Cleanup

- Source: `scripts/core/main_boot.gd`, `scripts/flow/boss_relic_reward.gd`, `resources/art/first_pass/menu/main_menu_logo_orbwalker_v1_alpha.png`, `docs/test_plan.md`, `wiki/main-menu-assets.md`
- Changed:
  - Ran Godot MCP validation on `res://scenes/main.tscn` (`get_project_info`, `view_script`, `get_godot_errors`, `play_scene`, `get_scene_tree`, `simulate_input`, runtime screenshot capture)
  - Fixed main-menu runtime binding issues in `scripts/core/main_boot.gd` by replacing `%ProfileButton`-style lookups with explicit footer paths and renaming local `scale` to `scale_factor` to avoid class-property shadow warnings
  - Fixed parse instability in `scripts/flow/boss_relic_reward.gd` by replacing `Variant`-inferred relic content assignment with explicit typed dictionary handling
  - Reprocessed `main_menu_logo_orbwalker_v1_alpha.png` to remove remaining checkerboard background regions visible at runtime
  - Updated `docs/test_plan.md` verification notes to record completed MCP checks and remaining manual steps
- Notes:
  - MCP input simulation confirmed `Start Run` routes from main menu to `res://scenes/combat/combat_player.tscn`.
  - `Debug Combat` routing target was verified through signal/method wiring inspection; direct mouse-click runtime confirmation remains a manual check item.

## [2026-04-30] code-change | Main Menu Runtime Defect Remediation

- Source: `scripts/core/main_boot.gd`, `docs/test_plan.md`, `wiki/features.md`, `wiki/main-menu-assets.md`
- Changed:
  - Fixed main-menu runtime overflow/overlap defects caused by texture-driven minimum sizing on logo/element/stat/footer controls
  - Added texture containment (`EXPAND_IGNORE_SIZE`), safe-area coordinate remap, icon-size clamps, and footer icon downscaling
  - Removed runtime bottom status-label overlap by disabling `StatusLabel` visibility
  - Documented screenshot-derived defect list and fix status in `docs/test_plan.md` and wiki pages
- Notes:
  - `Start Run` routing was revalidated through MCP input simulation after layout fixes.
  - Direct mouse-click verification for `Debug Combat` remains a manual check item.

## [2026-04-30] code-change | Main Menu Reference-Match Runtime Art Pass

- Source: `scenes/main.tscn`, `scripts/core/main_boot.gd`, `docs/test_plan.md`, `wiki/main-menu-assets.md`, `wiki/features.md`
- Changed:
  - Replaced flat frame panels with textured outer border runtime node (`OuterBorderTexture`) and removed the visible `DebugCombatButton` node/signal from `res://scenes/main.tscn`
  - Reworked `scripts/core/main_boot.gd` to load and apply mapped menu textures for outer border, button chrome, stats panel chrome, and menu icon families
  - Restaged main-menu composition toward the reference shape (larger logo, right-biased menu stack, larger element row, larger footer plates, stronger gold text hierarchy)
  - Preserved player-facing behavior constraints: `Start Run` remains functional; other menu/footer actions remain disabled placeholders
  - Updated QA and wiki pages to document the runtime textured pass and current manual verification gaps
- Notes:
  - Godot MCP checks in this pass (`get_godot_errors`, `play_scene`, `get_scene_tree`) were clean, and running scene-tree confirms `DebugCombatButton` is no longer present.
  - Remaining manual work is visual overlap/readability checks at `1080x1920`, `900x1600`, `1920x1080`, and `1366x768`, plus click-through confirmation from main menu into combat.

## [2026-04-30] code-change | Main Menu Checkerboard Alpha Cleanup

- Source: `resources/art/first_pass/menu/`, `tools/asset_tools/clean_menu_art.py`, `scripts/core/main_boot.gd`, `docs/test_plan.md`, `wiki/main-menu-assets.md`, `wiki/features.md`, `wiki/file-map.md`
- Changed:
  - Added `tools/asset_tools/clean_menu_art.py` for generated main-menu chrome/icon alpha cleanup
  - Reprocessed the menu outer border, primary/secondary button plates, stats triptych panel, and all `main_menu_icon_*` PNGs so transparent regions use alpha instead of baked checkerboard pixels
  - Adjusted `scripts/core/main_boot.gd` texture-style margins for compressed menu button/footer/stat plates so the cleaned art renders visibly at runtime
  - Updated QA and wiki docs to record the checkerboard fix and remaining multi-resolution visual QA
- Notes:
  - Godot MCP `play_scene`, `get_running_scene_screenshot`, and `get_godot_errors` passed after the cleanup; the running screenshot no longer shows the opaque checkerboard overlay.

## [2026-04-30] code-change | Character Art Polish Wiring

- Source: `tools/asset_tools/generate_character_placeholders.py`, `resources/art/first_pass/enemies/`, `resources/art/first_pass/heroes/`, `resources/visual/first_pass_asset_map.json`, `scripts/ui/visual_registry.gd`, `scripts/combat/combat_player_controller.gd`, `scripts/flow/shop_player.gd`, `docs/test_plan.md`
- Changed:
  - Added deterministic placeholder portrait generator `tools/asset_tools/generate_character_placeholders.py`
  - Added runtime portrait assets: `hero_orbwalker`, `enemy_ruin_lancer`, `enemy_vault_executioner`, `enemy_goldbound_keeper`
  - Expanded `VisualRegistry` enemy portrait mapping for all current run encounter IDs and added `hero_portrait()` accessor
  - Updated combat portrait binding to refresh `EnemyPortrait` from `_enemy_state.enemy_id` and bind `PlayerPortrait` from shared hero portrait
  - Updated shop footer portrait binding to use the same shared hero portrait accessor
  - Updated visual asset map with complete `enemy_portraits` and shared `hero_portraits` entries
  - Updated `docs/test_plan.md`, `wiki/features.md`, and `wiki/file-map.md`
- Notes:
  - Godot MCP checks passed for script parse/runtime health and runtime first-encounter portrait binding (`enemy_1` + hero).
  - Runtime boss-step and shop-step portrait progression still require manual interactive playthrough to observe in a single run flow.

## [2026-04-30] docs | Project Codex Agent Defaults

- Source: `.codex/config.toml`, `.codex/agents/`
- Changed:
  - Added project-local Codex default model settings in `.codex/config.toml`
  - Added custom Codex agents for `default`, `explorer`, and `worker`
  - Updated `wiki/setup.md` and `wiki/file-map.md` with the project-local Codex configuration
- Notes:
  - The requested `gpt-55` explorer model was recorded using the available Codex model slug `gpt-5.5`.

## [2026-04-30] docs | Multi-Agent Workflow Guidance

- Source: `AGENTS.md`, `.codex/agents/`
- Changed:
  - Added a multi-agent workflow section to `AGENTS.md`
  - Documented the `default`, `explorer`, and `worker` role responsibilities
  - Updated `wiki/setup.md` and `wiki/file-map.md` to reference the new operating guidance
- Notes:
  - The workflow keeps orchestration in the default agent unless the human explicitly asks for subagents or parallel work.

## [2026-04-30] docs | Default Multi-Agent Milestone Workflow

- Source: `AGENTS.md`, `.codex/agents/`
- Changed:
  - Revised `AGENTS.md` so milestone-style implementation prompts use the multi-agent workflow by default
  - Updated `.codex/agents/default.toml`, `.codex/agents/explorer.toml`, and `.codex/agents/worker.toml` descriptions/instructions for the default orchestration flow
  - Updated `wiki/setup.md` to document the default multi-agent milestone behavior
- Notes:
  - The default flow is task generation by `default`, exploration and planning research by `explorer`, implementation by `worker`, and summary/documentation by `default`.

## [2026-04-30] docs | Explicit Spawn Model Overrides

- Source: `AGENTS.md`, `.codex/agents/default.toml`
- Changed:
  - Clarified that role names alone do not select spawned subagent models
  - Required explicit spawn model overrides for `explorer` and `worker`
  - Updated `wiki/setup.md` with the explicit model override requirement
- Notes:
  - `explorer` should be spawned with `gpt-5.5`; `worker` should be spawned with `gpt-5.3-codex-spark`.

## [2026-04-30] docs | Rewrite Project Agent Guide

- Source: `AGENTS.md`
- Changed:
  - Rewrote `AGENTS.md` from a generic wiki maintenance template into a project-specific operating guide
  - Preserved source-of-truth rules, default multi-agent milestone workflow, explicit spawn model overrides, Godot MCP validation rules, wiki workflow, safety rules, and completion criteria
- Notes:
  - The new guide is shorter and focused on Matchatro/Orbwalker work in this repository.

## [2026-04-30] docs | Worker-Only Code Editing In Multi-Agent Mode

- Source: `AGENTS.md`, `.codex/agents/default.toml`, `.codex/agents/worker.toml`
- Changed:
  - Clarified that source/runtime code edits in multi-agent mode are done only by `worker`
  - Added step-by-step phase rules for default task generation, explorer investigation/planning, worker implementation, and default documentation handoff
  - Updated default and worker agent instructions to preserve the role boundary
- Notes:
  - `default` may still edit documentation, wiki, `AGENTS.md`, and `.codex/` orchestration files.

## [2026-04-30] code-change | Elemental Mastery Combat Feedback Panel

- Source: `scenes/combat/combat_player.tscn`, `scripts/combat/combat_player_controller.gd`, `scripts/ui/player_loadout_hud.gd`, `scripts/ui/visual_registry.gd`, `tools/asset_tools/generate_mastery_beam_placeholders.py`, `resources/art/first_pass/derived/vfx/`, `docs/test_plan.md`
- Changed:
  - Moved visible combat mastery from the bottom player HUD into a dedicated `ElementalMasteryPanel` above the player panel
  - Added six compact mastery cards with icon, level, fixed-height progress strip, and transient match feedback labels
  - Added match-time mastery feedback accumulation during resolve animations, plus card pulse and temporary elemental beam VFX from board matches to the matching mastery card
  - Added deterministic temporary mastery beam placeholder PNGs for fire, ice, earth, heart, armor, and gold
  - Updated `VisualRegistry` with `mastery_beam_texture(orb_id)`
  - Updated `docs/test_plan.md`, `wiki/features.md`, and `wiki/file-map.md`
- Notes:
  - Godot MCP parse, scene instantiate, beam texture, runtime smoke, running tree, and feedback-format probes passed.
  - Manual live-match visual acceptance is still needed for beam readability and cascade timing.

## [2026-04-30] code-change | Elemental Mastery Reference Replay Revamp

- Source: `scenes/combat/combat_player.tscn`, `scripts/combat/combat_player_controller.gd`, `scripts/ui/player_loadout_hud.gd`, `scripts/ui/visual_registry.gd`, `tools/asset_tools/generate_mastery_reference_assets.py`, `resources/art/first_pass/derived/ui_chrome/`, `resources/art/first_pass/derived/vfx/`, `docs/test_plan.md`, `wiki/features.md`, `wiki/file-map.md`
- Changed:
  - Rebuilt combat mastery as a taller reference-style six-card panel between the board and player HUD
  - Replaced the previous compact temporary beam assets with generated panel frame, card chrome, beams, armor shell, and hit/heal/gold impact PNGs with alpha transparency
  - Moved mastery beams out of cascade resolution and into a post-cascade left-to-right replay driven by `turn_log`
  - Added visual replay for enemy block before HP damage, player heal/armor/gold effects, and enemy attack armor-before-HP removal
  - Updated visual registry loading so newly generated repo PNGs can load before Godot writes `.import` metadata
- Notes:
  - Combat math remains in `CombatStateMachine`; this pass adds controller-level replay and presentation only.
  - Godot MCP disk-source parse, scene instantiate, asset probe, runtime scene-tree bounds, and no-runtime-error checks passed; live manual drag-turn review is still needed for animation feel.

## [2026-04-30] code-change | Elemental Mastery Panel Visual Correction

- Source: `scripts/combat/combat_player_controller.gd`, `scripts/ui/player_loadout_hud.gd`, `docs/test_plan.md`, `wiki/features.md`
- Changed:
  - Applied the generated mastery panel frame at runtime behind the mastery title and card row
  - Expanded the mastery panel to 216 design-space pixels tall and centered the title above the cards
  - Replaced combat-card mastery icon textures with combat orb textures to remove the white square backing visible in the previous screenshot
  - Increased combat-card icons to `84x84` and verified card internals fit inside six `160x176` cards
- Notes:
  - Godot MCP source load, scene instantiate, runtime scene-tree, and no-runtime-error checks passed.
  - Manual drag-turn review is still needed for animation timing and final screenshot acceptance.

## [2026-04-30] code-change | Elemental Mastery Feedback Slot Cleanup

- Source: `scripts/ui/player_loadout_hud.gd`, `docs/test_plan.md`, `wiki/features.md`
- Changed:
  - Removed the unused combat-card `MasteryProgress` bar under each mastery orb
  - Moved `MasteryFeedback` into the freed lower card slot and increased its label height for readability
- Notes:
  - Godot MCP source load, scene instantiate, runtime scene-tree, and no-runtime-error checks passed.

## [2026-04-30] code-change | Elemental Mastery Icon And Card Cleanup

- Source: `scripts/ui/visual_registry.gd`, `scripts/ui/player_loadout_hud.gd`, `tools/asset_tools/generate_mastery_reference_assets.py`, `resources/art/first_pass/derived/icons/`, `resources/art/first_pass/derived/ui_chrome/`
- Changed:
  - Combat mastery cards now use `menu_mastery_icon(orb_id)` to load the same six derived mastery icons reused by the main menu
  - Regenerated the six mastery card chrome PNGs without baked glimmer-strip or rune-stack marks
  - Kept card labels, levels, and effect feedback rendered by Godot rather than baked into assets
- Notes:
  - Godot MCP source load, scene instantiate, runtime scene-tree, registry texture-path probe, and no-runtime-error checks passed.

## [2026-04-30] docs-change | Codex Agent Model Alignment

- Source: `AGENTS.md`, `.codex/config.toml`, `.codex/agents/default.toml`, `.codex/agents/explorer.toml`, `.codex/agents/worker.toml`, `wiki/setup.md`
- Changed:
  - Aligned current Codex agent documentation around `default` as `gpt-5.5` with `low` reasoning, `explorer` as `gpt-5.5` with `medium` reasoning, and `worker` as `gpt-5.3-coder` with `high` reasoning
  - Updated the setup wiki to reflect the current project-local agent matrix
- Notes:
  - This was a documentation and project-local Codex config audit only; Godot runtime validation was not needed.

## [2026-04-30] code-change | Elemental Mastery HUD Variant Gallery

- Source: `scenes/ui/elemental_mastery_hud_variants.tscn`, `scripts/ui/elemental_mastery_hud_variants.gd`, `docs/tmp_elemental_mastery_visual_issues.md`, `wiki/features.md`, `wiki/file-map.md`
- Changed:
  - Added a standalone scrollable UI scene with five Elemental Mastery HUD variants for visual comparison against the attached reference
  - Variants cover reference-faithful, current combat-fit, taller-section, reduced-border-noise, and feedback-ready directions
- Notes:
  - Godot MCP `view_script`, `open_scene`, `play_scene`, `get_scene_tree`, `get_running_scene_screenshot`, and `get_godot_errors` checks passed with no runtime errors reported.
  - The scene is not hooked into combat flow; the selected variant still needs to be ported into combat runtime layout after review.

## [2026-04-30] code-change | Elemental Mastery Variant Crop Fix

- Source: `scripts/ui/elemental_mastery_hud_variants.gd`, `docs/tmp_elemental_mastery_visual_issues.md`
- Changed:
  - Reworked preview cards to avoid `STRETCH_KEEP_ASPECT_COVERED` cropping for the landscape mastery card art
  - Added contained art regions, circular icon medallions, and separate name/level/feedback lanes so labels do not sit on top of oversized cropped art
- Follow-up:
  - Replaced generated icon textures in the preview cards with procedural element marks after the derived icon assets still produced checkerboard, padding, or bleed artifacts at preview scale
  - The comparison scene now prioritizes readable layout selection over final asset fidelity
- Notes:
  - Godot MCP `view_script`, `open_scene`, `play_scene`, `get_scene_tree`, `get_running_scene_screenshot`, and `get_godot_errors` checks passed with no runtime errors reported.

## [2026-05-01] code-change | Elemental Mastery Preview Symbol Icons

- Source: `tools/asset_tools/generate_mastery_symbol_icons.py`, `resources/art/first_pass/derived/icons/mastery_symbol_*.png`, `scripts/ui/elemental_mastery_hud_variants.gd`, `docs/tmp_elemental_mastery_visual_issues.md`, `wiki/features.md`, `wiki/file-map.md`
- Changed:
  - Added a repeatable asset step that generates six transparent symbol-only mastery PNGs for Fire, Ice, Earth, Heart, Armor, and Gold preview cards
  - Updated the Elemental Mastery HUD variant gallery to use those generated symbol textures inside clipped circular medallions instead of empty, letter, old sheet, or full-badge placeholders
  - Enlarged the preview medallions and icon stages so the five variants read closer to the dark/gold reference while preserving the six-card order and fit
- Notes:
  - Godot MCP `view_script`, `open_scene`, `play_scene`, `get_running_scene_screenshot`, and `get_godot_errors` checks passed on the standalone preview scene after targeted texture reimport.
  - This remains preview-only; live combat `ElementalMasteryPanel` was not changed.

## [2026-05-01] code-change | Elemental Mastery Reference Preview Assets

- Source: `tools/asset_tools/generate_mastery_symbol_icons.py`, `resources/art/first_pass/derived/ui_chrome/mastery_preview_*.png`, `resources/art/first_pass/derived/icons/mastery_preview_emblem_*.png`, `scripts/ui/elemental_mastery_hud_variants.gd`, `docs/tmp_elemental_mastery_visual_issues.md`, `wiki/features.md`, `wiki/file-map.md`
- Changed:
  - Expanded the preview asset generator to create a tall reference-style panel frame, six portrait card backgrounds, and six ornate emblem badges for the HUD variant gallery
  - Updated the standalone Elemental Mastery HUD comparison scene to use the generated preview frame/card/emblem textures with a separated title band and lower six-card row
  - Preserved the five preview variants and kept the change out of live combat runtime
- Notes:
  - Godot MCP `view_script`, `open_scene`, targeted texture reimport, `play_scene`, `get_running_scene_screenshot`, `get_scene_tree`, `get_godot_errors`, and `stop_running_scene` checks passed with no runtime errors or image-load export warnings.

## [2026-05-01] code-change | Elemental Mastery Real Preview Icons

- Source: `scripts/ui/elemental_mastery_hud_variants.gd`, `tools/asset_tools/generate_mastery_symbol_icons.py`, `resources/art/first_pass/derived/icons/mastery_*.png`, `resources/art/first_pass/derived/ui_chrome/mastery_preview_*.png`, `docs/tmp_elemental_mastery_visual_issues.md`, `wiki/features.md`, `wiki/file-map.md`
- Changed:
  - Replaced generated preview emblem usage with the existing real main-menu mastery icons for Fire, Ice, Earth, Heart, Armor, and Gold
  - Stopped the preview chrome generator from recreating generated symbol or emblem placeholder icon files
  - Removed generated preview emblem and symbol icon outputs from the worktree
- Notes:
  - Godot MCP `view_script`, `open_scene`, targeted texture reimport, `play_scene`, `get_running_scene_screenshot`, `get_scene_tree`, `get_godot_errors`, and `stop_running_scene` checks passed with no runtime errors or image-load export warnings.

## [2026-05-01] docs | Elemental Mastery Preview Tool Naming

- Source: `tools/asset_tools/generate_mastery_preview_chrome.py`, `docs/tmp_elemental_mastery_visual_issues.md`, `wiki/features.md`, `wiki/file-map.md`
- Changed:
  - Renamed the preview asset generator documentation target from symbol-icon generation to preview chrome generation so the current workflow is explicit: chrome is generated, badge icons come from existing real mastery icon assets.

## [2026-05-01] code-change | Elemental Mastery Variant 5 Combat Integration

- Source: `scripts/combat/combat_player_controller.gd`, `scripts/ui/player_loadout_hud.gd`, `resources/art/first_pass/derived/ui_chrome/mastery_preview_panel_frame.png`, `resources/art/first_pass/derived/ui_chrome/mastery_preview_card_*.png`, `resources/art/first_pass/derived/icons/mastery_*.png`, `docs/tmp_elemental_mastery_visual_issues.md`, `wiki/features.md`, `wiki/file-map.md`
- Changed:
  - Ported the selected `Feedback Ready` variant into live combat as a `1048 x 368` Elemental Mastery panel with full-width title band, centered six-card row, preview panel/card chrome, real mastery icons, and reserved lower feedback lanes.
  - Rebalanced the combat board zone upward/smaller so the taller mastery panel fits between board and player HUD without overlap.
- Notes:
  - Godot MCP `view_script`, `open_scene res://scenes/combat/combat_player.tscn`, `play_scene current`, `get_running_scene_screenshot`, `search_nodes`, `get_node_properties`, `execute_editor_script`, `get_godot_errors`, and `stop_running_scene` checks passed with no runtime errors. Running-scene properties confirmed the selected panel/card geometry and real icon/card texture paths; editor-script probes confirmed nonzero feedback text renders in the reserved lower lane.

## [2026-05-01] code-change | Combat Minimal Chrome Taste Pass

- Source: `scripts/combat/combat_player_controller.gd`, `scripts/ui/player_loadout_hud.gd`, `wiki/features.md`
- Changed:
  - Rebalanced live combat into neutral, flatter panels with thinner borders and less gold chrome.
  - Converted the live Elemental Mastery combat panel from the large ornate variant frame into a compact flat six-card rail while preserving mastery feedback labels and replay VFX source cards.
  - Repositioned the player HUD internals to fit the expanded footer area after compacting mastery.
- Notes:
  - Godot MCP `play_scene current`, `get_scene_tree`, `get_node_properties`, and `get_godot_errors` checks passed with no runtime errors. Running-scene geometry confirmed board, compact mastery, and player panel zones do not overlap.

## [2026-05-01] code-change | Combat Player HUD Spacing Tightening

- Source: `scripts/ui/player_loadout_hud.gd`
- Changed:
  - Moved the combat footer hero card, vitals panel, and equipment/consumable loadout upward inside the player panel to remove the oversized empty gap between HP and loadout.
- Notes:
  - Godot MCP `play_scene current`, `get_scene_tree`, and `get_godot_errors` checks passed with no runtime errors. Running-scene geometry confirmed the player HUD sections remain visible and non-overlapping.

## [2026-05-02] code-change | Shop Page Polish

- Source: `scripts/flow/shop_player.gd`, `scripts/ui/visual_registry.gd`, `wiki/features.md`
- Changed:
  - Added an image-backed merchant stage layer with backdrop, scrim, and counter band so the shop page reads closer to the supplied reference instead of a flat debug panel.
  - Rebalanced stock and relic card internals around rarity, name, larger item art, shorter description lanes, and price badges without changing buy/sell/reroll behavior.
  - Routed booster fire/elemental icon fallback to the existing fire mastery icon so booster cards avoid plain color-block placeholder art.
- Notes:
  - Godot MCP `get_project_info`, `view_script`, `execute_editor_script` scene instantiate probe, and `get_godot_errors` were used. A stale pre-fix booster fallback warning remained in the Godot log buffer, but the post-fix editor-script probe confirmed `booster_fire` resolves to a non-null icon.

## [2026-05-02] code-change | Reusable Player Footer

- Source: `scripts/ui/player_loadout_hud.gd`, `scripts/combat/combat_player_controller.gd`, `scripts/flow/shop_player.gd`, `wiki/features.md`
- Changed:
  - Added `PlayerLoadoutHud.apply_player_footer_layout(...)` as the explicit reusable footer layout contract and switched combat/shop call sites to it.
  - Removed shop-only footer gold and relic nodes from `shop_player.gd`; shop now uses a combat-style player HUD structure with Elemental Mastery as the sibling rail above `PlayerPanel`, and the shared footer inside `PlayerPanel` for hero portrait, HP, equipment, and consumables.
  - Kept shop gold in the top bar and left shop offers, relic offer, reroll, sell, continue, and booster behavior unchanged.
- Notes:
  - Godot MCP `view_script`, `execute_editor_script` scene instantiate checks, combat `play_scene`, combat running scene-tree inspection, and `get_godot_errors` checks passed. A follow-up source/parse check confirmed the shop footer-root offset was removed and `ElementalMasteryPanel` is no longer parented under `PlayerPanel`. Shop runtime scene-tree inspection still needs an active-run launch path because playing the shop scene directly redirects to main when the game-process `RunState` is inactive.

## [2026-05-02] code-change | Connected Shared Player HUD

- Source: `scenes/combat/combat_player.tscn`, `scripts/ui/player_loadout_hud.gd`, `scripts/combat/combat_player_controller.gd`, `scripts/flow/shop_player.gd`, `docs/test_plan.md`, `wiki/features.md`, `wiki/file-map.md`
- Changed:
  - Promoted `PlayerLoadoutHud` from footer-only layout helper to the shared full player HUD contract with `apply_player_hud_layout(...)` and `apply_player_hud_chrome(...)`.
  - Added a connected `PlayerHudSection` layout shared by combat and shop: fixed bottom section, Elemental Mastery rail, footer panel, hero portrait, HP, equipment, and consumables.
  - Reparented combat `ElementalMasteryPanel` and `PlayerPanel` under `PlayerHudSection` and normalized combat subpanels to marginless `Panel` nodes so shop and combat rects match.
  - Rebuilt shop's player area as the same `PlayerHudSection` hierarchy and compacted merchant, stock, relic, and action regions above the locked HUD position without changing shop economy or interaction behavior.
- Notes:
  - Godot MCP `view_script`, scene load/instantiate probes, combat `play_scene` running-tree inspection, an active-run shop probe, and final `get_godot_errors` checks passed. Runtime geometry confirmed combat and shop share `PlayerHudSection` `(0,1092) 1080x828`, mastery `(16,0) 1048x172`, footer `(0,188) 1080x640`, and non-overlapping shop action row ending at `y=1076`.

## [2026-05-02] code-change | Sequential Same-Pass Match Presentation

- Source: `scripts/combat/combat_player_controller.gd`, `docs/test_plan.md`, `wiki/features.md`
- Changed:
  - Changed combat resolve presentation so same-pass match groups are sorted by top row then left column and shown one at a time.
  - Moved each visible group through flash, clear animation, visual clear commit, combo tick, and Elemental Mastery preview before the next same-pass group begins.
  - Kept gravity and refill after all groups in the pass so resolver logic, combo totals, and cascade outcomes remain unchanged.
- Notes:
  - Godot MCP `get_project_info`, `view_script`, `get_godot_errors`, `play_scene current`, and an editor-script ordering probe passed. Manual real-drag feel acceptance remains useful because the change is presentation timing.

## [2026-05-02] code-change | Centered Scaling Combo Text

- Source: `scripts/combat/combat_player_controller.gd`, `docs/test_plan.md`, `wiki/features.md`
- Changed:
  - Replaced match-relative combo popup placement with a fixed center-stage position over the board.
  - Removed the combo popup panel border/background so the readout behaves like floating text.
  - Increased combo font and pulse scale as the combo count rises.
- Notes:
  - Godot MCP `view_script`, `get_godot_errors`, and combat scene smoke checks passed. Manual real-drag feel acceptance remains useful.

## [2026-05-02] code-change | Combat Speed Timing Setting

- Source: `scripts/combat/combat_player_controller.gd`, `docs/test_plan.md`, `wiki/features.md`
- Changed:
  - Renamed the hidden post-drag presentation speed setting to `combat_speed`.
  - Defined four combat speed modes: `slow`, `normal`, `fast`, and `instant`.
  - Set the default combat speed to `normal`.
- Notes:
  - Godot MCP `view_script`, `get_godot_errors`, and combat scene smoke checks passed.

## [2026-05-02] code-change | Dungeon Playthrough Flow Fixes

- Source: `scripts/combat/combat_player_controller.gd`, `scripts/core/run_state.gd`, `scripts/flow/shop_player.gd`, `scripts/shop/shop_service.gd`, `scripts/run/player_progression_service.gd`, `scripts/ui/player_loadout_hud.gd`, `todo.md`, `docs/test_plan.md`, `wiki/features.md`, `wiki/known-issues.md`
- Changed:
  - Moved normal boss relic selection into the combat victory overlay with explicit relic choice or skip before continuing to the post-boss shop.
  - Kept `res://scenes/flow/boss_relic_reward.tscn` as legacy/debug fallback instead of the normal `RunState.next_scene_path()` player route.
  - Added booster full-slot replacement and discard flow for equipment and consumables, with replacement APIs enforcing active shop, pending booster options, and filled target slots.
  - Extended the shared `PlayerLoadoutHud` footer to render owned relic icons with compact overflow in both combat and shop.
- Notes:
  - Godot MCP `view_script`, `get_godot_errors`, combat/shop scene instantiate probes, and worker runtime probes passed. Manual end-to-end playthrough remains useful for visual acceptance of the full boss victory to shop path.

## [2026-05-02] code-change | Booster Skip And Sell Bubble

- Source: `scripts/flow/shop_player.gd`, `docs/test_plan.md`, `todo.md`, `wiki/features.md`
- Changed:
  - Changed the pending booster overlay so its scrim ignores mouse input and no longer blocks the shared player HUD.
  - Replaced the booster replacement/discard UI presentation with a single Skip button; full-slot picks now keep the booster choices open and instruct the player to sell from the HUD or skip.
  - Moved shop selling out of the bottom action row into a contextual sell bubble near the selected equipment slot.
- Notes:
  - Godot MCP `view_script`, shop scene instantiate, and `get_godot_errors` passed. Worker runtime smoke also reported no session errors, but full pending-booster UI interaction should still be visually checked in an active run.

## [2026-05-02] code-change | Shop Offer Filtering And Consumable Sell

- Source: `scripts/shop/shop_service.gd`, `scripts/run/player_progression_service.gd`, `scripts/core/run_state.gd`, `scripts/flow/shop_player.gd`, `scripts/ui/player_loadout_hud.gd`, `wiki/features.md`
- Changed:
  - Filtered generated shop stock and booster option equipment candidates to exclude items already equipped by the player.
  - Added consumable selling support through progression and shop services, with a `RunState.sell_consumable_item(...)` wrapper used by the shop scene.
  - Extended shared HUD slot selection to include consumables and wired shop sell bubble flow to sell either selected equipment or selected consumable.
  - Moved shared HUD relic label/icons to a row between HP and the equipment/consumable rows.
- Notes:
  - Godot MCP `view_script`, `execute_editor_script`, and `get_godot_errors` were run. Service probes confirmed shop and booster equipment filtering plus consumable selling, scene instantiate probes passed for combat and shop, and latest `get_godot_errors` reported no parse/runtime errors.

## [2026-05-02] code-change | Unified Shop Inventory Popover

- Source: `scripts/flow/shop_player.gd`, `wiki/features.md`
- Changed:
  - Replaced separate overlapping shop HUD slot detail and sell bubbles with one shared non-clipped inventory popover.
  - Moved Sell into the same popover for equipment/consumable slot hovers or selected slots, while relic slot popovers remain details-only.
  - Kept the existing selected-slot sell flow by wiring the new popover Sell action to the same selection-based sell handler.
  - Added inventory-focus dismissal so clicking outside inventory slots/popover or using non-inventory shop actions clears the selected slot and hides the popover without breaking the embedded Sell action.
- Notes:
  - Godot MCP `view_script`, `get_godot_errors`, and scene instantiate/probe (`play_scene` + `get_scene_tree`) were run; latest reported no session errors.

## [2026-05-02] code-change | Placeholder Audio Hooks

- Source: `scripts/core/audio_manager.gd`, `project.godot`, `scripts/core/main_boot.gd`, `scripts/combat/combat_player_controller.gd`, `scripts/flow/shop_player.gd`, `todo.md`, `docs/test_plan.md`, `wiki/features.md`, `wiki/file-map.md`
- Changed:
  - Added an `AudioManager` autoload that generates placeholder looped music and short SFX tones in code, so the prototype has audio feedback without imported audio assets.
  - Wired menu, combat, and shop music contexts.
  - Wired SFX hooks for menu start, combat match/combo/result/victory/defeat events, and shop purchase/reroll/sell/booster success or failure feedback.
  - Added lazy `/root/AudioManager` resolution in scene controllers so audio works in already-open editor sessions before the new autoload is refreshed.
- Notes:
  - Godot MCP `view_script`, script load probes, main-scene runtime smoke, scene instantiate probes, and `get_godot_errors` passed. Manual listening and volume/feel review remains pending.

## [2026-05-02] code-change | MIDI Music Export

- Source: `raw/`, `tools/audio/export_midi_to_wav.py`, `resources/audio/music/`, `scripts/core/audio_manager.gd`, `docs/test_plan.md`, `todo.md`, `wiki/features.md`, `wiki/file-map.md`, `wiki/setup.md`
- Changed:
  - Added a Python MIDI-to-WAV export helper that renders raw MIDI files through the local FluidSynth binary and `raw/GeneralUser GS v1.471.sf2`.
  - Exported `combat.wav`, `credit.wav`, `main-menu.wav`, `melody.wav`, and `shop.wav` into `resources/audio/music/`.
  - Updated `AudioManager` so menu/combat/shop music uses exported WAV assets when present and falls back to generated loops when missing.
- Notes:
  - Current exporter uses FluidSynth, signed 16-bit WAV output, WAV header verification, and PCM peak normalization. Godot MCP filesystem scan, WAV load probe, and `get_godot_errors` passed. Manual listening and loop-point review remains pending.

## [2026-05-02] fix | Audible Music Levels

- Source: `tools/audio/export_midi_to_wav.py`, `resources/audio/music/`, `scripts/core/audio_manager.gd`, `scripts/core/main_boot.gd`, `scripts/combat/combat_player_controller.gd`, `scripts/flow/shop_player.gd`, `docs/test_plan.md`, `todo.md`, `wiki/features.md`
- Changed:
  - Normalized exported WAV music to a louder peak target during MIDI export.
  - Raised `AudioManager` music playback from `-20 dB` to `-8 dB`.
  - Added music-player volume enforcement after scene music requests so already-open editor sessions do not keep stale quiet child-player settings.
- Notes:
  - WAV RMS/peak checks now show audible music data. Godot MCP `view_script` and `get_godot_errors` passed. Manual listening remains the final acceptance check.

## [2026-05-02] fix | FluidSynth WAV Export

- Source: `tools/audio/export_midi_to_wav.py`, `resources/audio/music/`, `wiki/features.md`, `wiki/file-map.md`, `wiki/setup.md`
- Changed:
  - Replaced the Python synth rendering path with the provided local FluidSynth binary.
  - Fixed FluidSynth argument ordering so `-F output.wav` is supplied before the SoundFont and MIDI files.
  - Regenerated all music WAVs as signed 16-bit stereo 44.1 kHz files and normalized their PCM peak levels.
- Notes:
  - Python `wave` checks passed for all exported files, and Godot MCP loaded every WAV as `AudioStreamWAV`.

## [2026-05-02] fix | Main Menu Direct Music

- Source: `scripts/core/main_boot.gd`, `resources/audio/music/main-menu.wav`, `docs/test_plan.md`, `todo.md`, `wiki/features.md`
- Changed:
  - Added a direct `MainMenuMusicPlayer` under the main menu scene.
  - Deferred main-menu music startup until after menu layout setup.
  - Kept the global `AudioManager` music request after direct startup for later scene-transition consistency.
- Notes:
  - Godot MCP confirmed `MainMenuMusicPlayer` exists in the running main scene and `get_godot_errors` reported no session errors. Manual listening remains the acceptance check.

## [2026-05-02] fix | Main Menu PCM Music Playback

- Source: `scripts/core/main_boot.gd`, `resources/audio/music/main-menu.wav`, `docs/test_plan.md`, `todo.md`, `wiki/features.md`
- Changed:
  - Changed main menu music loading to parse the source signed 16-bit WAV and create an in-memory `AudioStreamWAV`, bypassing Godot's imported WAV resource path.
  - Set main-menu music to `0 dB` for focused audibility testing.
  - Added a retry loop if playback stops.
- Notes:
  - Runtime log confirmed main-menu music playback on the Master bus. User confirmed the music was audible, then the direct menu music volume was lowered from `0 dB` to `-12 dB` for mix comfort. Godot MCP `get_godot_errors` reported no session errors before the volume adjustment.

## [2026-05-02] tune | Main Menu Music Volume

- Source: `scripts/core/main_boot.gd`, `docs/test_plan.md`, `wiki/log.md`
- Changed:
  - Lowered direct main-menu music playback from `0 dB` to `-12 dB` after user reported it was too loud.
- Notes:
  - This is a mix adjustment only; no source asset or export pipeline changes.

## [2026-05-02] fix | Start Run Music Restart

- Source: `scripts/core/main_boot.gd`, `docs/test_plan.md`, `todo.md`, `wiki/features.md`
- Changed:
  - Removed the first-input main-menu music restart workaround.
  - Kept the non-invasive retry guard that only resumes music if the player stops.
- Notes:
  - Start Run clicks no longer call `stop()` then `play()` on `MainMenuMusicPlayer` before scene transition.

## [2026-05-02] fix | Combat Source WAV Music

- Source: `scripts/core/audio_manager.gd`, `scripts/combat/combat_player_controller.gd`, `scripts/flow/shop_player.gd`, `scripts/core/main_boot.gd`, `docs/test_plan.md`, `todo.md`, `wiki/features.md`, `wiki/file-map.md`
- Changed:
  - Moved reliable music loading into `AudioManager` by opening the absolute project WAV and decoding signed 16-bit PCM into an in-memory `AudioStreamWAV` before falling back to Godot's imported resource.
  - Set shared music playback to `-12 dB` and removed scene-level `-8 dB` overrides.
  - Allowed same-key music requests to restart playback if the music player has stopped.
- Notes:
  - Godot MCP confirmed `combat.wav` decodes through `AudioManager` as stereo 44.1 kHz PCM with 14,012,416 data bytes and loop end 3,503,104. A direct combat scene smoke printed `AudioManager music playing: key=combat stream=AudioStreamWAV volume_db=-12.0 bus=Master`. Manual listening remains the final acceptance check.

## [2026-05-02] code-change | Combat Orb Swap SFX

- Source: `scripts/core/audio_manager.gd`, `scripts/combat/combat_player_controller.gd`, `docs/test_plan.md`, `todo.md`, `wiki/features.md`
- Changed:
  - Added a short generated `swap` SFX to `AudioManager`.
  - Played the `swap` SFX after each valid adjacent combat orb swap during drag movement.
- Notes:
  - The hook is on the actual `_board_state.swap_cells(...)` path, so invalid moves and stationary pointer movement do not play the sound. Manual listening remains the final acceptance check.

## [2026-05-03] code-change | Player HUD API Ownership

- Source: `scripts/ui/player_loadout_hud.gd`, `scripts/combat/combat_player_controller.gd`, `scripts/flow/shop_player.gd`, `docs/test_plan.md`, `wiki/features.md`
- Changed:
  - Promoted `PlayerLoadoutHud` from shared layout helper to the shared player-HUD owner for combat and shop.
  - Added `bind_player_hud(...)`, `load_player_data(...)`, `update_player_data(...)`, `update_player_hud_layout()`, `handle_global_click(...)`, and `sell_slot_requested` as the HUD-facing API.
  - Moved item detail popover ownership, slot selection, outside-click focus clearing, and sell button presentation into `PlayerLoadoutHud`.
  - Reduced combat/shop controllers to data passing plus scene-specific sale handling for equipment and consumables.
- Notes:
  - Godot MCP `view_script`, `get_godot_errors`, and combat/shop scene instantiate probes passed. Manual active-run click-through remains useful for visual placement and interaction feel.

## [2026-05-03] fix | Android Portrait And Keyboard Startup

- Source: `project.godot`, `scripts/combat/combat_player_controller.gd`, `.gitignore`, `docs/test_plan.md`, `wiki/features.md`
- Changed:
  - Added `display/window/handheld/orientation=1` so Android exports request portrait orientation.
  - Removed startup focus from the hidden combat debug console and release its focus when the debug overlay closes, preventing Android from opening the soft keyboard on combat entry.
  - Ignored generated Android package artifacts such as `*.apk`, `*.aab`, `*.apks`, and `*.idsig`.
- Notes:
  - Godot MCP `view_script`, `play_scene current` for `res://scenes/combat/combat_player.tscn`, running scene-tree inspection, and `get_godot_errors` passed. A debug APK exported and installed on connected device `b21e3ea8` with `adb install -r`.

## [2026-05-03] fix | Android Board Scaling And Audio Loading

- Source: `scripts/combat/combat_player_controller.gd`, `scripts/ui/player_loadout_hud.gd`, `scripts/core/audio_manager.gd`, `scripts/core/main_boot.gd`, `todo.md`, `docs/test_plan.md`, `wiki/features.md`, `wiki/file-map.md`
- Changed:
  - Updated combat layout so tall portrait viewports keep width-based scaling, expand the design-space root height, grow the board first, and extend the shared player HUD instead of centering the fixed 1080x1920 root with top/bottom dead space.
  - Added a `PlayerLoadoutHud` layout override API so combat can move/size `PlayerHudSection` dynamically while shop keeps the default shared HUD layout.
  - Changed menu/combat/shop music loading to prefer imported `res://` audio streams in template/export builds before direct source-WAV decoding, keeping generated SFX active.
- Notes:
  - Godot MCP `view_script`, `get_godot_errors`, computed layout probes for 1080x1920/1080x2400/900x1600, `play_scene current`, running scene-tree inspection, imported WAV/SFX probes, and main-menu music smoke passed. A debug Android APK exported and installed on connected device `b21e3ea8` with `adb install -r`; the existing MCP plugin Android `arm64` warning remains. Android on-device visual and listening acceptance remains pending.

## [2026-05-03] config | Android Launcher Icon

- Source: `export_presets.cfg`, `raw/icon.png`, `docs/test_plan.md`
- Changed:
  - Pointed Android `launcher_icons/main_192x192` and `launcher_icons/adaptive_foreground_432x432` at `res://raw/icon.png`.
- Notes:
  - A debug Android APK exported and installed on connected device `b21e3ea8` with `adb install -r`; the existing MCP plugin Android `arm64` warning remains.

## [2026-05-03] fix | Android Touch And Music Regressions

- Source: `scripts/combat/combat_player_controller.gd`, `scripts/core/audio_manager.gd`, `scripts/core/main_boot.gd`, `docs/test_plan.md`, `todo.md`, `wiki/features.md`, `wiki/file-map.md`
- Changed:
  - Fixed Android combat board touch selection by using `BoardView.gui_input` local touch positions directly instead of applying a second screen-to-board transform.
  - Routed Android/template main-menu music through `AudioManager`, restored WAV/imported music as the first choice for Android/template menu/combat/shop, and kept generated music as fallback only.
  - Configured imported `AudioStreamWAV` loop bounds before playback so exported WAV music can loop with a positive loop end.
  - Added audio diagnostics that log music source, Android/template flags, stream class, playing state, volume, and bus.
- Notes:
  - Godot MCP `view_script`, `get_godot_errors`, main scene smoke, and combat scene smoke passed with no session errors. Debug Android APK export succeeded with the existing MCP plugin Android `arm64` warning, but `adb install -r` could not run because no Android device/emulator was connected. Android on-device touch and listening retest remains required.

## [2026-05-03] fix | Android Music Loop Length

- Source: `scripts/core/audio_manager.gd`, `scripts/core/main_boot.gd`, `docs/test_plan.md`
- Changed:
  - Changed Android/template WAV loading to try direct PCM decode from the exported `res://resources/audio/music/*.wav` source before imported fallback.
  - Made imported WAV fallback compute loop end from the source WAV header when possible, avoiding early loops from compressed imported sample payload size.
  - Disabled internal `AudioStreamWAV` looping on Android/template music playback and added manual restart from `AudioStreamPlayer.finished`.
  - Expanded Android music diagnostics to include source, manual restart state, loop mode/end, source frame count, and stream data bytes.
- Notes:
  - Godot MCP `view_script` and `get_godot_errors` passed. Android on-device loop timing retest remains required.

## [2026-05-03] config | Android Boot Splash Image

- Source: `project.godot`, `raw/spash.png`, `wiki/setup.md`, `wiki/file-map.md`
- Changed:
  - Set the project boot splash image to `res://raw/spash.png` and kept boot splash image display enabled.
  - Documented the boot splash asset reference in setup and file-map notes.
- Notes:
  - The asset currently exists as `raw/spash.png`; no raw asset rename was performed.

## [2026-05-03] fix | Android Raw WAV Music Payload

- Source: `scripts/core/audio_manager.gd`, `resources/audio/raw_music/`, `docs/test_plan.md`, `wiki/features.md`, `wiki/file-map.md`
- Changed:
  - Added Android/template raw music source mapping in `AudioManager` for menu/combat/shop to prefer `res://resources/audio/raw_music/{menu,combat,shop}.wav.bin` before imported WAV fallback.
  - Copied full byte-for-byte source WAV payloads from `resources/audio/music/` into `resources/audio/raw_music/` using non-imported `.wav.bin` files so exported packages can decode full WAV header/data.
  - Added `resources/audio/raw_music/*.wav.bin` to the Android export include filter so these non-imported payloads are packaged in the APK.
  - Extended music diagnostics to track both source type and source path (`raw_pcm_wav` vs imported fallback) and compute frame counts from the actual selected payload path.
- Notes:
  - Godot MCP parse/error checks passed after the fix. Android on-device listening and loop-length confirmation is still pending.

## [2026-05-03] diagnostic | Run Transition FlowTrace

- Source: `scripts/core/run_state.gd`, `scripts/core/main_boot.gd`, `scripts/combat/combat_player_controller.gd`, `scripts/flow/shop_player.gd`, `docs/test_plan.md`, `docs/tmp_transition_delay_handoff.md`, `wiki/known-issues.md`
- Changed:
  - Added temporary FlowTrace timing for Start Run, combat, and shop run-flow scene transitions.
  - Split traced transition timing into resource load, packed-scene instantiation, scene attach, destination scene startup, and first usable frame markers.
  - Recorded user runtime evidence that `Start Run -> Combat` spends about `2.47s` in `PackedScene.instantiate()` for `res://scenes/combat/combat_player.tscn`.
- Notes:
  - Godot MCP script/error checks passed during implementation; existing integer-division warnings remain unrelated. Next diagnostic pass should isolate `combat_player.tscn`, `board_surface.tscn`, theme resources, and script initializer instantiation cost before changing transition architecture.

## [2026-05-03] fix | Combat Transition Instantiate Delay

- Source: `scripts/ui/visual_registry.gd`, `scripts/ui/player_loadout_hud.gd`, `scripts/combat/combat_player_controller.gd`, `docs/tmp_transition_delay_handoff.md`, `docs/test_plan.md`, `wiki/known-issues.md`
- Changed:
  - Moved `VisualRegistry` texture loading/building from eager `_init()` work to lazy accessor-specific builders.
  - Let `PlayerLoadoutHud` receive the combat controller's `VisualRegistry` instead of constructing a duplicate registry.
  - Deferred combat's orb texture-map build until after the first usable frame so the remaining runtime orb cleanup no longer blocks scene entry.
- Notes:
  - Godot MCP probes measured `VisualRegistry.new()` around `0.013ms`, `PlayerLoadoutHud.new()` around `0.008ms`, `combat_player.tscn` instantiate around `67ms`, and direct combat first usable frame around `149ms`.
  - User route-level validation from the real Start Run button measured combat resource load around `206ms`, instantiate around `1ms`, attach around `83ms`, first usable frame around `300ms`, and deferred orb texture-map completion around `1438ms`.
  - User route-level validation for the sampled Combat -> Shop path measured shop resource load around `52ms`, instantiate around `0ms`, attach around `140ms`, and first usable frame around `245ms`.
  - The deferred orb texture-map pass still costs about `1.1s-1.2s`, so preprocessed orb textures remain a useful follow-up if visual pop-in is noticeable.
