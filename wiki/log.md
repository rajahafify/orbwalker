# Wiki Log

## 2026-05-06 - Generic Scene Change Rollback Recovery

- Fixed and documented the remaining generic FlowTrace rollback gap: `RunState.flow_trace_change_scene(...)` now forwards post-ready failure callbacks into prepared scene attach, and locked callers in main menu Collection, Collection back, shop redirects/continue/main-menu, final-summary Main Menu, and combat route helpers pass local recovery callbacks so deferred post-ready rollback unlocks restored controls or shows a retryable combat overlay. Validation is recorded in `docs/test_plan.md`. (source: `scripts/core/run_state.gd`, `scripts/core/main_boot.gd`, `scripts/flow/collection.gd`, `scripts/flow/shop_player.gd`, `scripts/flow/final_run_summary.gd`, `scripts/combat/combat_player_controller.gd`, `docs/test_plan.md`)
- Follow-up fix: the generic scene-change API now also accepts rollback snapshots, and shop Continue captures one before `advance_after_shop(false)` so immediate or deferred scene-change failure restores the shop/run state as well as unlocking the visible shop UI. (source: `scripts/core/run_state.gd`, `scripts/flow/shop_player.gd`, `docs/test_plan.md`)

## 2026-05-06 - Transition Failure Recovery Follow-Up

- Fixed and documented two scene-review findings: prepared-scene attach payloads now support a post-ready failure callback so Start Run and final-summary New Run unlock their restored old UI if deferred post-ready rollback fires, and combat outcome routing now checks scene-change return codes, logs failure, restores the pending target path, and shows a retryable outcome overlay instead of dropping failed route results. Validation passed `git diff --check`, Godot MCP script reloads for the touched files, scene instantiate smoke for main/combat/final summary, and final `get_godot_errors` with no session errors. (source: `scripts/core/run_state.gd`, `scripts/core/main_boot.gd`, `scripts/flow/final_run_summary.gd`, `scripts/combat/combat_player_controller.gd`, `docs/test_plan.md`)

## 2026-05-06 - Prepared Scene Post-Ready Guard

- Documented and validated the review follow-up: `RunState.flow_trace_attach_prepared_scene(...)` now keeps the old scene disabled/hidden until the prepared scene survives a deferred post-ready frame, logs `post_ready_check` before freeing the old scene, and restores the supplied rollback snapshot plus old scene if that health check fails. Start Run and final-summary New Run now pass rollback snapshots into the prepared scene payload. `CombatLayoutManager` enum assignments use fully-qualified enum values so the Godot MCP script reload gate is clean. Validation passed `git diff --check`, Godot MCP `view_script` for `combat_layout_manager.gd` and `final_run_summary.gd`, `play_scene main`, `stop_running_scene`, and final `get_godot_errors` with no session errors. (source: `scripts/core/run_state.gd`, `scripts/core/main_boot.gd`, `scripts/flow/final_run_summary.gd`, `scripts/combat/combat_layout_manager.gd`, `docs/test_plan.md`)

## 2026-05-06 - Scene Review Finding Cleanup

- Documented and validated the scene-review finding cleanup: `CombatLayoutManager` now casts enum-style layout assignments so the current Godot MCP error gate is clean, and `docs/scene_structure_refactor_plan.md` now treats the shop HUD preset cleanup as resolved while keeping the reusable HUD `.tscn` boundary as the remaining scene-structure target. Validation passed `git diff --check`, Godot MCP `view_script`, focused combat scene instantiate/load probe, `play_scene main`, `stop_running_scene`, and final `get_godot_errors` with no session errors. (source: `scripts/combat/combat_layout_manager.gd`, `docs/scene_structure_refactor_plan.md`, `docs/test_plan.md`)

## 2026-05-06 - Scene Review P1/P2 Cleanup

- Updated [[known-issues]], [[architecture]], [[file-map]], and [[features]] for the scene-review cleanup: `RunState` now supports split prepare/attach FlowTrace transitions, Start Run and final-summary New Run prepare combat before mutating run/audio state and restore snapshots on attach failure, shop ready-time redirects use traced scene-change recovery, and shop HUD internals now come from `PlayerLoadoutHud.shop_player_hud_layout_preset()` instead of shop-local geometry constants. The shop action-to-HUD gap remains 30 design pixels. Godot MCP validation passed for script loading, focused transition/HUD probes, scene instantiation, and route invariants; final main-scene smoke is recorded in `docs/test_plan.md`. (source: `scripts/core/run_state.gd`, `scripts/core/main_boot.gd`, `scripts/flow/final_run_summary.gd`, `scripts/flow/shop_player.gd`, `scripts/ui/player_loadout_hud.gd`, `docs/test_plan.md`)

## 2026-05-04 - CFR-08 Enemy Intent HP Preview

- Updated [[features]] for CFR-08 enemy intent HP preview: before the player moves, combat now computes projected incoming attack damage from attack intent entries and visible player HP/armor, then the shared HUD shows current player armor as a persistent full-height semi-transparent silver overshield on the HP bar, including armor from turn start and Armor matches. The old `BLOCK +N` badge is hidden in favor of that HP-bar armor visual. The HUD also shows a slower red-to-empty-to-red blinking HP danger segment for unblocked or partially blocked HP loss; the warning fades over an empty HP backing so the off phase does not reveal the normal red HP fill. Projected blocked player damage and enemy block intent use full-height semi-transparent silver overshield previews, scaled by block over max HP. Enemy intent preview entries now render as separate `Attack N` / `Block N` bubbles with no fixed two-intent limit for attack/block entries, and the retired scene `IntentBadge` / `EnemyIntentLabel` stay hidden so the old single-bubble display does not flash first. Hovering the HP danger preview scales/blinks attack bubbles while hovered; hovering an overshield preview scales/blinks block bubbles. This does not change combat math, enemy intent values, resolver behavior, RunState routing, enemy attack resolution, replay timing, board order, or `combat_speed`. Godot MCP validation passed on 2026-05-04; manual visual QA remains useful for real enemy-intent cases. (source: `scripts/combat/combat_player_controller.gd`, `scripts/ui/player_loadout_hud.gd`, `scripts/combat/combat_hud_snapshot_builder.gd`, `scenes/combat/combat_player.tscn`, `docs/combat_feedback_revamp_tasks.md`)

## 2026-05-04 - CFR-06 Enemy Attack Feedback

- Updated [[features]] for CFR-06 enemy attack feedback: enemy attacks now get a generic cue/travel visual from the enemy portrait, armor-block impacts for `blocked_by_armor`, HP hit impacts for `hp_damage`, and partial-block timing that steps visible armor before the HP damage read. The replay still reads existing `turn_log.enemy_attack_resolution` values and preserves combat math, resolver behavior, RunState routing, board order, `combat_speed`, blocked label text, and enemy attack SFX ownership. User visual QA passed on 2026-05-04 for fully blocked, partially blocked, and unblocked enemy attacks. (source: `scripts/combat/combat_player_controller.gd`, `scripts/combat/combat_vfx_manager.gd`, `docs/combat_feedback_revamp_tasks.md`)

## 2026-05-04 - CFR-04 Mastery Activation Readability

- Updated [[features]] for CFR-04 mastery activation readability: combat mastery cards now keep pooled contribution text but add fixed-size value-scaled activation glow/frame pulses, and mastery beams add a small source pulse at the active card so the player can read the card as the source. The change is presentation-only and preserves combat math, resolver behavior, RunState routing, board order, result labels, and `combat_speed`. (source: `scripts/ui/player_loadout_hud.gd`, `scripts/combat/combat_vfx_manager.gd`, `docs/combat_feedback_revamp_tasks.md`)

## 2026-05-04 - CFR-03 Combat Feedback Timing

- Updated [[features]] for CFR-03 source-to-target feedback timing: combat turn replay now keeps pre-turn HUD values staged while result labels and VFX play, advances visible enemy HP/block step-by-step after each elemental damage label, and advances player HP/armor and gold after the related result label. Blocked damage labels now use `-N Damage Blocked` for both enemy block and player armor block. Runtime combat math and final state remain owned by `CombatStateMachine`; the staged values are presentation-only in `CombatPlayerController` and the shared HUD HP display override. User manual timing/readability QA passed on 2026-05-04, so CFR-03 is closed in the tracker. (source: `scripts/combat/combat_player_controller.gd`, `scripts/ui/player_loadout_hud.gd`, `docs/combat_feedback_revamp_tasks.md`)

## 2026-05-04 - Combat Feedback Revamp Tracker

- Created `docs/combat_feedback_revamp_tasks.md` to break the combat feedback UI revamp into CFR-01 through CFR-07: baseline event inventory, floating result numbers, source-to-target timing, mastery activation readability, tiered elemental/resource VFX hooks, enemy attack feedback, and readability QA. (source: `docs/combat_feedback_revamp_tasks.md`)
- Linked the tracker from [[index]] so the next agent has a durable entry point for the Milestone 9 feedback-readability work. (source: `wiki/index.md`)

## 2026-05-04 - Post-Review Safety Cleanup

- Added post-review safety notes for shop traced scene-change failure unlocks, stale-reference guards in combat drag/layout helpers, explicit `PlayerState` mastery-provider binding, detailed armor-log formula correction, shared lazy `AudioManagerResolver`, and `UiUtils.clear_children(...)`. (source: `scripts/flow/shop_player.gd`, `scripts/combat/board_drag_input_handler.gd`, `scripts/combat/combat_layout_manager.gd`, `scripts/combat/player_state.gd`, `scripts/combat/combat_turn_logger.gd`, `scripts/core/audio_manager_resolver.gd`, `scripts/ui/ui_utils.gd`)
- Updated [[features]], [[file-map]], and [[known-issues]] to record the new helper ownership and the resolved shop transition-lock failure path. (source: `wiki/features.md`, `wiki/file-map.md`, `wiki/known-issues.md`)

## 2026-05-04 - AR-18 Architecture Review Closeout

- Closed the architecture-review tracker before Milestone 10 by adding AR-18, confirming AR-01 through AR-17 are documented, separating historical deleted-scene evidence from current validation surfaces, and classifying remaining work as Milestone 10 QA or later scoped cleanup. (source: `docs/architecture_review_tasks.md`, `docs/test_plan.md`, `todo.md`)
- Updated [[known-issues]] and [[index]] to narrow resolved AR route/touch gaps, document retained FlowTrace/ResolveTrace/AR-01 diagnostics as intentional QA tools, and point the current project focus at Milestone 10 balance and QA. (source: `wiki/known-issues.md`, `wiki/index.md`)

## 2026-05-04 - AR-13 Board Drag Input Handler Extraction

- Added [[architecture]], [[file-map]], and [[features]] notes for `scripts/combat/board_drag_input_handler.gd`, which now owns board-local mouse/touch drag event parsing, active drag state, touch-index tracking, selected orb/current cell/path tracking, adjacent-cell swap bookkeeping, move-timer countdown state, drag visual reset/abort, and match-glow refresh. `scripts/combat/combat_player_controller.gd` keeps input phase authority, timer/status presentation, resolve kickoff, combat math, presentation, VFX/layout/HUD, debug callbacks, `/skip`, routing, and scene transitions. (source: `scripts/combat/board_drag_input_handler.gd`, `scripts/combat/combat_player_controller.gd`)
- Recorded AR-13 completion in the architecture review tracker, todo, and test plan with Godot MCP `view_script`, focused script-load, helper state-transition probes, combat scene instantiate, retained AR-01 result-envelope, main-scene smoke, final no-session-error evidence, Android install verification, and user-confirmed manual QA for real mouse drag, Android touch drag, rapid-tap feel, cascade feel after drag release, and board coordinate accuracy. (source: `docs/architecture_review_tasks.md`, `todo.md`, `docs/test_plan.md`)

## 2026-05-04 - AR-12 Combat VFX Manager Extraction

- Added [[architecture]], [[file-map]], and [[features]] notes for `scripts/combat/combat_vfx_manager.gd`, which now owns transient combat VFX drawing mechanics: VFX layer binding, texture VFX spawning, replay impacts, mastery beam source lookup, global-to-layer coordinate conversion, beam sizing/rotation/z-index, and fade cleanup. `scripts/combat/combat_player_controller.gd` keeps turn-log decisions, replay order/waits, combat speed timing, mastery preview totals/release semantics, resolver simulation, combat math, input, layout, audio, debug callbacks, `/skip`, outcome routing, and scene transitions. (source: `scripts/combat/combat_vfx_manager.gd`, `scripts/combat/combat_player_controller.gd`)
- Recorded AR-12 completion in the architecture review tracker and test plan with Godot MCP `view_script`, helper reload/instantiate, focused VFX spawn, combat scene instantiate, retained AR-01 result-envelope, main-scene smoke, and final no-session-error evidence. Manual visual QA remains required for real mastery beams, impact placement, cascade readability, Android/on-device behavior, overlap checks, drag/cascade feel, orb texture pop-in, and rapid-tap feel. (source: `docs/architecture_review_tasks.md`, `docs/test_plan.md`)

## 2026-05-04 - Start Run Orb Texture Startup Fix

- Added generated clean combat orb textures under `resources/art/first_pass/derived/orbs/` and updated `VisualRegistry` to load those textures before falling back to runtime orb-sheet cleanup. (source: `scripts/ui/visual_registry.gd`, `resources/art/first_pass/derived/orbs/`)
- Recorded follow-up timing evidence: focused warm-cache `orb_texture()` probes measured about `12ms`, and live `Start Run -> Combat` tracing measured `combat_first_usable_frame` at `314ms` with `combat_after_texture_map` at `325ms`, replacing the old sampled `1.1s-1.2s` deferred cleanup delay. Manual visual pop-in and Android/on-device feel remain QA items. (source: `docs/test_plan.md`, `wiki/known-issues.md`)

## 2026-05-04 - AR-11 Combat Layout Manager Extraction

- Added [[architecture]], [[file-map]], and [[features]] notes for `scripts/combat/combat_layout_manager.gd`, which now owns combat scene geometry, responsive design-space scaling, board/player HUD layout rects, debug overlay anchors, and outcome overlay layout sync while `combat_player_controller.gd` keeps gameplay state, input, VFX, HUD data, routing, and timer state decisions. (source: `scripts/combat/combat_layout_manager.gd`, `scripts/combat/combat_player_controller.gd`)
- Recorded AR-11 completion in the architecture review tracker and test plan with Godot MCP script-load, scene instantiate, layout parity, retained AR-01 result-envelope, main-scene smoke, and final no-session-error evidence. Manual visual overlap, Android/on-device layout, drag/cascade feel, deferred orb texture-map pop-in, and rapid-tap feel remain broader QA gaps unless retested separately. (source: `docs/architecture_review_tasks.md`, `docs/test_plan.md`)

## 2026-05-04 - AR-10 Combat Controller God-Object Refactor

- Updated [[architecture]], [[file-map]], and [[features]] for the new combat debug/turn-log helper boundary: `scripts/combat/combat_debug_console.gd` owns command parsing and log rendering, `scripts/combat/combat_turn_logger.gd` owns turn-log and summary text, and `scripts/combat/combat_player_controller.gd` keeps privileged gameplay callbacks, `/skip`, routing, input, layout, and VFX. (source: `scripts/combat/combat_player_controller.gd`, `scripts/combat/combat_debug_console.gd`, `scripts/combat/combat_turn_logger.gd`)
- Recorded AR-10 completion in the architecture review tracker and test plan with Godot MCP script-load, scene instantiate, AR-01 result-envelope, turn-logger parity, and main-scene smoke evidence. Manual command click-through and Android/visual QA remain broader acceptance items unless retested separately. (source: `docs/architecture_review_tasks.md`, `docs/test_plan.md`)
- Added AR-11 through AR-17 tracker entries for the remaining combat-controller god-object refactor candidates: layout manager, VFX manager, board drag input handler, combat chrome/theme boundary, placeholder texture utility, HUD sync boundary review, and outcome/transition boundary review. (source: `docs/architecture_review_tasks.md`)

## 2026-05-03 - AR-07 RunState/Data Contract Roadmap

- Updated [[architecture]], [[file-map]], [[known-issues]], [[open-questions]], and [[decisions]] to record dictionary-backed `ContentRegistry` content as the prototype source of truth for this phase, with Resource/JSON migration deferred behind the registry API. (source: `docs/system_architecture.md`, `scripts/content/content_registry.gd`)
- Recorded AR-07 completion in the architecture review tracker, architecture-maintenance todo list, and test plan. `RunState.run_contract_snapshot()` and `ContentRegistry.content_contract_snapshot()` now document the live compatibility contracts, and `ContentRegistry` single-item getters return duplicated dictionaries to prevent caller mutation of the registry index. (source: `scripts/core/run_state.gd`, `scripts/content/content_registry.gd`, `docs/architecture_review_tasks.md`, `docs/test_plan.md`)

## 2026-05-03 - AR-05 Combat Controller First Split

- Updated [[architecture]] and [[file-map]] for the new `CombatOutcomeOverlay` helper ownership split: outcome overlay presentation moved to `scripts/combat/combat_outcome_overlay.gd`, while `scripts/combat/combat_player_controller.gd` keeps combat orchestration, RunState outcome routing, debug commands, and resolver replay timing. (source: `scripts/combat/combat_player_controller.gd`, `scripts/combat/combat_outcome_overlay.gd`, `docs/architecture_review_tasks.md`)
- Recorded AR-05 completion in the architecture review tracker, architecture-maintenance todo list, and test plan with Godot MCP evidence plus user manual QA confirmation. (source: `docs/architecture_review_tasks.md`, `todo.md`, `docs/test_plan.md`)

## 2026-05-03 - AR-01 Baseline Harness Gaps

- Updated [[known-issues]] with AR-01 baseline gaps for repeated unsourced integer-division reload warnings and the current Godot MCP editor-script limitation around deterministic combat result-envelope probes that touch `RunState`. (source: `docs/test_plan.md`, `docs/architecture_review_tasks.md`, `scripts/combat/combat_state_machine.gd`, `scripts/core/run_state.gd`)
- Added user-captured AR-01 route timing baselines for `Start Run -> Combat`, `Combat -> Shop`, and `Shop -> Combat`; the remaining route performance risk is deferred combat texture-map completion after first usable frame. (source: `docs/test_plan.md`, `wiki/known-issues.md`)
- Added retained feature-flagged AR-01 combat result-envelope probe documentation and closed the earlier result-envelope blocker after Godot MCP returned `status=ok`. (source: `scripts/debug/ar01_combat_result_probe.gd`, `scripts/combat/combat_state_machine.gd`, `docs/test_plan.md`, `docs/architecture_review_tasks.md`)

Append-only history of wiki operations.

## [2026-05-03] docs | Architecture Review Task Tracking Plan

- Source: `docs/architecture_review_tasks.md`, `todo.md`, `docs/test_plan.md`, `wiki/index.md`, `wiki/architecture.md`, `wiki/file-map.md`, `wiki/known-issues.md`
- Changed:
  - Created `docs/architecture_review_tasks.md` with eight architecture-review tasks, each tracked with `Status`, `Owner/scope`, `Progress`, `Blockers`, `Next action`, `Validation`, and `Docs/wiki impact`.
  - Added an `Architecture Maintenance: Review Task Tracking Plan` section in `todo.md` before Milestone 10 and linked the new tracker.
  - Added a `Regression Harness / Architecture Refactor QA` checklist section in `docs/test_plan.md`.
  - Linked the architecture review tracker from the wiki index, architecture page, and file map.
  - Updated `wiki/known-issues.md` with confirmed architecture-review risks and tracker linkage.
- Validation:
  - Documentation-only pass; no runtime/Godot validation was executed in this change.

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

## [2026-05-03] code-change | Defeat Final Summary Route

- Source: `scripts/core/run_state.gd`, `scripts/combat/combat_player_controller.gd`, `docs/test_plan.md`, `docs/architecture_review_tasks.md`, `wiki/features.md`, `wiki/file-map.md`
- Changed:
  - Changed finalized defeat routing to open `res://scenes/flow/final_run_summary.tscn` in defeat mode instead of returning directly to main menu.
  - Kept reset/no-summary inactive `RunState` routing pointed at `res://scenes/main.tscn`.
  - Updated normal and debug defeat outcome overlays to show `Run Summary` as the handoff action.
- Validation:
  - Godot MCP route probe confirmed reset inactive, new run, and finalized defeat routes; scene instantiate passed for main, combat, shop, and final summary.
  - Retained AR-01 combat result-envelope probe still matched baseline, `play_scene main` launched with no session errors, and `git diff --check` passed.

## [2026-05-03] code-change | AR-08 Fallback Scene Retirement

- Source: `AGENTS.md`, `scripts/core/run_state.gd`, `scripts/combat/combat_player_controller.gd`, `scenes/flow/final_run_summary.tscn`, `scripts/flow/final_run_summary.gd`, `docs/architecture_review_tasks.md`, `docs/test_plan.md`, `todo.md`, `wiki/features.md`, `wiki/file-map.md`, `wiki/known-issues.md`, `wiki/setup.md`
- Changed:
  - Renamed the final victory summary surface from `run_summary_placeholder` to `final_run_summary`.
  - Removed the old boss relic reward scene/script now that boss relic choices live in the combat victory overlay.
  - Removed the old shop placeholder scene/script.
  - Removed the board-debug scene/controller and updated current validation guidance to use player-facing scenes plus focused Godot MCP probes.
- Validation:
  - Godot MCP script checks, route probes, scene instantiate checks, main-scene smoke, deleted-reference searches, and `git diff --check` passed.
- Notes:
  - Historical validation entries in this log may still mention deleted debug/fallback surfaces as past evidence.

## [2026-05-03] code-change | AR-08 Cleanup And Dead-Code Validation

- Source: `scripts/combat/player_state.gd`, `scripts/combat/combat_state_machine.gd`, `scripts/flow/run_summary_placeholder.gd`, `docs/architecture_review_tasks.md`, `docs/test_plan.md`, `todo.md`, `wiki/file-map.md`, `wiki/known-issues.md`
- Changed:
  - Removed confirmed-unused `PlayerState.base_orb_values`.
  - Removed confirmed-unused `CombatStateMachine.PLAYER_EFFECT_ORDER`.
  - Removed unused legacy run-summary formatting helpers `_format_summary()`, `_format_slots()`, and `_format_ids()`.
  - Recorded that `run_summary_placeholder.tscn`, `boss_relic_reward.tscn`, and `shop_placeholder.tscn` are retained route/fallback surfaces, not AR-08 deletion targets.
- Validation:
  - PowerShell source/scene reference checks found no remaining references to the removed symbols.
  - Godot MCP `view_script`, retained AR-01 result-envelope probe, RunState route probes, scene instantiate probes, `play_scene main`, `get_godot_errors`, and `git diff --check` passed.
- Notes:
  - Manual visual QA for drag/cascade feel, overlap checks, Android/on-device behavior, and deferred orb texture-map pop-in remains outside this cleanup pass.

## [2026-05-03] fix | AR-02 Low-Risk Fixes
- Source: `scripts/combat/enemy_state.gd`, `scripts/core/main_boot.gd`, `scripts/core/audio_manager.gd`, `scripts/flow/shop_player.gd`, `scripts/flow/boss_relic_reward.gd`, `scripts/flow/shop_placeholder.gd`, `docs/architecture_review_tasks.md`, `docs/test_plan.md`, `wiki/features.md`
- Changes:
  - Made `EnemyState.get_current_intent()` return a duplicated intent snapshot before adding the derived `index`, keeping the caller contract unchanged while making the method non-mutating by construction.
  - Stopped main-menu music retry polling after successful desktop playback or Android/template `AudioManager` routing, while preserving retries when setup fails.
  - Gated verbose `AudioManager` music diagnostics behind `debug/audio_diagnostics_enabled=false` by default while preserving the detailed diagnostic output when explicitly enabled.
  - Added duplicate-transition guards for Start Run, player-shop Continue/Menu, legacy boss-reward Skip/Continue, and legacy shop Skip/Next/Menu; guarded advance handlers surface failed `RunState` transition reasons instead of routing anyway.
  - Follow-up user rapid-click QA found shop music could remain audible under the desktop main menu after `Shop -> Main Menu`; desktop main-menu startup now stops any shared `AudioManager` music before local menu playback.
  - `AudioManager.audio_diagnostics_opt_in_enabled()` now returns `false` without querying or registering a missing `debug/audio_diagnostics_enabled` setting, removing the reported nonexistent-setting error.
  - User-confirmed rapid-click QA passed after the handoff fix: returning from shop lands on main menu once, shop music stops, only main-menu music remains audible, and no new diagnostics-setting error was observed.
  - Godot MCP intent snapshot probe, main scene music smoke, audio diagnostic setting probe, transition scene instantiate probe, focused shared-music stop probe, retained AR-01 combat result-envelope probe rerun, and `git diff --check` passed; known unsourced integer-division reload warnings remain.

## [2026-05-03] code-change | AR-03 Shared WAV Audio Utility
- Source: `scripts/core/audio_stream_loader.gd`, `scripts/core/audio_manager.gd`, `scripts/core/main_boot.gd`, `docs/architecture_review_tasks.md`, `docs/test_plan.md`, `wiki/features.md`, `wiki/file-map.md`
- Changes:
  - Added `AudioStreamLoader` as the shared helper for file byte loading, signed PCM16 WAV parsing, imported stream loop setup, WAV loop bounds, and source-frame counts.
  - Updated `AudioManager` and `main_boot.gd` to call the shared loader instead of carrying duplicate WAV helper implementations.
  - Preserved generated music/SFX ownership in `AudioManager`, desktop main-menu local playback, shared `AudioManager` stop before desktop menu music, and Android/template menu routing through `AudioManager`.
  - Godot MCP post-change probes matched baseline menu/combat/shop WAV loop ends and data bytes, confirmed generated `swap` SFX still builds, reran the retained AR-01 combat result-envelope probe, and launched `play_scene main` with no session errors. Android/on-device listening was not retested.
  - Follow-up user listening found the desktop Start Run music handoff could drop during scene transition. `main_boot.gd` now stops the local menu player and starts shared `AudioManager` combat music before transition; Godot MCP focused handoff probe confirmed shared combat music stays playing before the combat scene starts, and user manual listening confirmation passed after the fix.

## [2026-05-03] code-change | AR-04 Shop Input Safety
- Source: `scripts/ui/player_loadout_hud.gd`, `scripts/flow/shop_player.gd`, `docs/architecture_review_tasks.md`, `docs/test_plan.md`, `wiki/features.md`, `wiki/known-issues.md`
- Changes:
  - Made shared HUD hover preview-only so equipment and consumable selection is committed by slot press instead of mouse hover.
  - Gated HUD Sell to the selected hovered equipment or consumable slot so moving the pointer over another slot cannot arm a sale.
  - Added same-frame guards around player-shop buy, relic buy, reroll, sell, booster pick, and booster skip handlers to prevent duplicate transaction execution from repeated activation in one input frame.
  - Routed shop touch outside-dismissal through the same `PlayerLoadoutHud.handle_global_click(...)` path as mouse outside clicks.
  - Godot MCP `view_script`, focused HUD selection/sell/outside-click probes, same-frame shop action guard probe, shop scene instantiate probe, and final `get_godot_errors` passed. Android/on-device touch acceptance and live visual click-through remain manual QA.
  - Manual QA found real shop outside-dismissal still failed on PC and Android because handled UI events did not reach `_unhandled_input`; shop dismissal now runs from `_input` without marking the event handled so normal shop controls still receive clicks/taps. Godot MCP source-shape, scene instantiate, and error checks passed after the follow-up.
  - Manual QA then found the popover closed but selected slot chrome stayed active. The outside-dismiss path now clears inventory focus and refreshes the shop UI for mouse/touch dismissal so selection clears visually as well as logically. Godot MCP `view_script` and `get_godot_errors` passed after the follow-up, and user manual QA confirmed the fix on PC and Android.
  - Android CLI export repeatedly wrote a valid `Orbwalker.apk` but hung before process exit, leaving a Godot console process and Java/Gradle child. The updated APK installed successfully with `adb install -r`, and the export hang/workaround is now documented in `wiki/setup.md`, `wiki/known-issues.md`, and `docs/test_plan.md`.
## 2026-05-03

- Completed AR-06 combat presentation split. `scripts/combat/combat_resolve_presenter.gd` now owns the board-space resolve replay presentation boundary while `scripts/combat/combat_player_controller.gd` retains resolver simulation, combat math, RunState routing, outcome overlay routing, debug console, and `/skip`. Validation notes were added to `docs/test_plan.md`; manual visual QA remains required for real drag/cascade feel, overlap checks, Android/on-device behavior, and deferred orb texture-map pop-in. (source: `docs/architecture_review_tasks.md`, `docs/test_plan.md`, `scripts/combat/combat_resolve_presenter.gd`, `scripts/combat/combat_player_controller.gd`)
- User manual QA on the installed Android build confirmed AR-06 presentation behavior works. `docs/architecture_review_tasks.md` and `docs/test_plan.md` were updated to record the accepted manual pass and keep broader overlap/pop-in review as non-AR-06 follow-up. (source: `docs/architecture_review_tasks.md`, `docs/test_plan.md`)
## [2026-05-03] code-change | AR-09 Stability And Shared UI Utility Cleanup

- Source: `scripts/combat/combat_player_controller.gd`, `scripts/combat/combat_resolve_presenter.gd`, `scripts/core/main_boot.gd`, `scripts/flow/final_run_summary.gd`, `scripts/flow/shop_player.gd`, `scripts/ui/ui_utils.gd`, `docs/architecture_review_tasks.md`, `docs/test_plan.md`, `wiki/features.md`, `wiki/file-map.md`, `wiki/known-issues.md`
- Changed:
  - Added lifecycle guards around combat resolve/turn replay continuation points and bounded the presenter animation drain so invalid scene/board state or stuck animation flags do not resume indefinitely.
  - Routed the combat wrong-step redirect through `RunState.flow_trace_change_scene(...)`, added Start Run failure recovery, and guarded final-summary `Start New Run` / `Main Menu` actions with disabled buttons while routing.
  - Added `UiUtils.panel_style(...)` as the shared flow-scene `StyleBoxFlat` helper and migrated shop/final-summary panel styling without changing the previous border/radius/margin mapping.
- Validation:
  - `git diff --check`, Godot MCP `view_script` checks, scene instantiate probes for main/combat/final-summary, `UiUtils.panel_style(...)` mapping probe, `play_scene main`, and `get_godot_errors` passed.
  - User manual sanity QA on 2026-05-04 confirmed Start Run, combat resolve/cascade feel, combat routing, final-summary actions, shop regression, and visible panel styling are all good. Android/on-device behavior, full viewport overlap sweep, and deferred orb texture-map pop-in remain broader manual QA unless retested separately.

## [2026-05-04] code-change | AR-14 Combat Theme And Chrome Boundary

- Source: `scripts/combat/combat_player_controller.gd`, `scripts/combat/combat_chrome_styler.gd`, `docs/architecture_review_tasks.md`, `docs/test_plan.md`, `todo.md`, `wiki/architecture.md`, `wiki/file-map.md`, `wiki/features.md`
- Changed:
  - Added `CombatChromeStyler` as the combat code-built chrome/style helper for shared frame styleboxes, progress bars, label font/color overrides, timer-track/readability styling, button chrome, board/outcome panel chrome, stat chips, debug overlay font sizing, shared player-HUD chrome dispatch, and debug zone-guide chrome.
  - Kept `CombatPlayerController` responsible for scene node ownership, `_apply_visual_chrome()` orchestration, timer runtime text/fill/color math, placeholder texture creation/assignment, layout, VFX, input, combat math, resolve presentation, route transitions, debug callbacks, `/skip`, and `UiUtils.panel_style(...)` non-combat ownership.
- Validation:
  - `git diff --check`, Godot MCP `view_script` checks, focused script-load checks, combat scene instantiate probe, representative style-value probe, retained AR-01 combat result-envelope probe, `play_scene main`, and final `get_godot_errors` passed.
  - User manual QA passed after the helper extraction.

## [2026-05-04] code-change | AR-15 Combat Placeholder Texture Utility

- Source: `scripts/combat/combat_player_controller.gd`, `scripts/combat/combat_placeholder_textures.gd`, `docs/architecture_review_tasks.md`, `docs/test_plan.md`, `todo.md`, `wiki/architecture.md`, `wiki/file-map.md`, `wiki/features.md`
- Changed:
  - Added `CombatPlaceholderTextures` as the focused combat helper for code-generated timer, intent, enemy portrait, and hero portrait placeholder textures.
  - Kept `CombatPlayerController` responsible for placeholder fallback decisions, `VisualRegistry` lookups, scene-node texture assignment, visibility toggles, timer runtime behavior, layout, chrome styling, combat math, route transitions, debug callbacks, and `/skip`.
- Validation:
  - `git diff --check`, Godot MCP `view_script` checks, focused texture dimension/color/alpha probe, focused script-load and combat scene instantiate probe, retained AR-01 combat result-envelope probe, `play_scene main`, and final `get_godot_errors` passed.
  - A separate async scene-ready texture-assignment probe hit an MCP tool-script parse limitation before execution; user manual QA passed after the helper extraction.

## [2026-05-04] code-change | AR-16 Combat HUD Sync Boundary

- Source: `scripts/combat/combat_player_controller.gd`, `scripts/combat/combat_hud_snapshot_builder.gd`, `docs/architecture_review_tasks.md`, `docs/test_plan.md`, `todo.md`, `wiki/architecture.md`, `wiki/file-map.md`, `wiki/features.md`
- Changed:
  - Added `CombatHudSnapshotBuilder` as the side-effect-free combat HUD snapshot dictionary helper for top HUD, enemy stage, timer/tempo row, player strip, and debug overlay data.
  - Kept `CombatPlayerController` responsible for applying snapshots to scene labels/bars/nodes, dispatching `PlayerLoadoutHud` payloads, loadout rail layout refresh, placeholder fallback assignment, combat-only enemy/timer/status behavior, debug callbacks, routing, and `/skip`.
- Validation:
  - `git diff --check`, Godot MCP `get_project_info`, `view_script` checks, focused HUD snapshot and combat/shop instantiate probe, retained AR-01 combat result-envelope probe, `play_scene main`, and final `get_godot_errors` passed.
  - User manual QA passed after the HUD snapshot boundary extraction, covering the AR-16 combat/shop HUD acceptance surface.

## 2026-05-04

- AR-17 combat outcome transition boundary review found a narrow behavior-preserving helper inside `scripts/combat/combat_player_controller.gd`: `_trace_and_change_scene_to_target(...)` now owns duplicated combat outcome trace/change-scene glue for standard Continue, boss reward claim, and boss reward skip. `RunState` still owns route semantics and summaries, and `CombatOutcomeOverlay` still owns presentation. Automated Godot MCP validation passed, and user manual QA found no issues or errors across the outcome-route checklist. Updated [[architecture]], [[file-map]], and [[features]]. (source: `scripts/combat/combat_player_controller.gd`, `docs/architecture_review_tasks.md`, `docs/test_plan.md`)
- Post-closeout review added two transition failure-path follow-ups to [[known-issues]] and the AR-18 tracker context: final-summary `Start New Run` should not leave `RunState` reset if the combat scene transition fails, and Start Run failure recovery should restore menu audio if the transition fails after switching to combat music. These are documented as failure-path issues, not accepted normal-route blockers. (source: `scripts/flow/final_run_summary.gd`, `scripts/core/main_boot.gd`, `docs/architecture_review_tasks.md`)
- Documented the AR closeout god-object status for `combat_player_controller.gd`: the controller is down from the pre-AR estimate of about 3357 lines to 2432 lines, with the original leaf helper targets extracted and the remaining risk framed as coordinator-scale combat flow, HUD application, and turn orchestration boundaries. Updated [[architecture]], [[file-map]], [[known-issues]], and the AR-18 tracker context. (source: `docs/architecture_review_tasks.md`, `scripts/combat/combat_player_controller.gd`)
- CFR-02 implementation added floating combat result labels for turn-log-sourced enemy damage, healing, armor gain, gold gain, enemy block, enemy attack block, and player HP damage. The label system lives in `CombatVfxManager` on the existing `VfxLayer`, while replay timing stays in `CombatPlayerController`; a Godot MCP rerun reached the editor, loaded the edited scripts, instantiated combat with `VfxLayer`, spawned all eight label kinds in a focused probe, and launched `play_scene current`. User manual QA passed the full CFR-02 visual matrix on 2026-05-04, so CFR-02 is closed; the final `get_godot_errors` call still retained earlier enum reload diagnostics from before the casts were fixed and should be treated as stale unless they reappear after editor restart. Updated [[features]]. (source: `scripts/combat/combat_player_controller.gd`, `scripts/combat/combat_vfx_manager.gd`, `docs/combat_feedback_revamp_tasks.md`)
## [2026-05-04] code-change | CFR-04 Mastery Feedback Release Follow-Up

- Source: `scripts/combat/combat_player_controller.gd`, `scripts/ui/player_loadout_hud.gd`, `scripts/combat/combat_vfx_manager.gd`, `docs/combat_feedback_revamp_tasks.md`, `docs/test_plan.md`, `wiki/features.md`
- Changed:
  - Preserved active combat mastery feedback totals through shared HUD rebuilds so staged replay HUD updates do not clear every lit mastery card at once.
  - Strengthened the mastery beam source pulse at the card/icon so the beam origin is easier to read during replay.
- Notes:
  - Godot MCP script reload, combat scene instantiate, focused active-card rebuild/release probe, source pulse/beam probe, `play_scene current`, and `get_godot_errors` checks passed. The only reported session errors were the known stale CFR-02 enum reload diagnostics.

## [2026-05-04] code-change | CFR-04 Mastery Effect SFX

- Source: `scripts/combat/combat_player_controller.gd`, `scripts/core/audio_manager.gd`, `docs/combat_feedback_revamp_tasks.md`, `docs/test_plan.md`, `wiki/features.md`
- Changed:
  - Added impact-timed Mastery Effect SFX for replayed damage, heal, armor, and gold effects using the existing placeholder `hit`, `heal`, `armor`, and `gold` sounds.
  - Removed mastery damage/heal/armor/gold playback from the post-replay turn result SFX batch so replay effects do not double-trigger sounds.
  - Kept source launch visual-only and preserved the existing enemy attack hit SFX lane.
- Notes:
  - Godot MCP script reload, SFX stream probe, source-timing probe, `play_scene current`, and `get_godot_errors` checks passed. User visual/listening QA passed on 2026-05-04. The only reported session errors were the known stale CFR-02 enum reload diagnostics.

## [2026-05-04] code-change | CFR-05 VFX Tier Hooks

- Source: `scripts/combat/combat_vfx_manager.gd`, `scripts/combat/combat_player_controller.gd`, `docs/combat_feedback_revamp_tasks.md`, `docs/test_plan.md`, `wiki/features.md`
- Changed:
  - Added `CombatVfxManager`-owned temporary thresholds for Fire, Ice, Earth, Heart, Armor, and Gold replay impacts.
  - Added four positive presentation-only VFX tiers that scale existing/fallback impact size, lifetime, alpha, brightness, positive result-label font size, label outline, and label container size.
  - Routed existing `turn_log` replay values from `CombatPlayerController` into the tiered impact and positive-label helpers without changing combat math, replay order, label text, SFX timing, staged HUD stepping, or `combat_speed`.
  - Increased visible tier scale to `1.0`, `1.5`, `2.0`, `3.0` and lowered early-run thresholds after visual feedback showed the first pass was too subtle.
- Notes:
  - Godot MCP script checks, focused tier-boundary probe, lowered-threshold probe, positive-label font-tier probe, combat scene-node probe, all-six-kind tiered impact spawn probe, `play_scene current`, and `git diff --check` passed.
  - User visual QA passed on 2026-05-04. The first helper probe hit a stale cached script before passing with `ResourceLoader.CACHE_MODE_IGNORE`; final `get_godot_errors` still reported the known stale CFR-02 enum reload diagnostics.

## [2026-05-05] code-change | CFR-09 Pre-Drag Mastery Hover Readability

- Source: `scripts/board/board_view.gd`, `scripts/combat/combat_player_controller.gd`, `scripts/ui/player_loadout_hud.gd`, `docs/combat_feedback_revamp_tasks.md`, `docs/test_plan.md`, `wiki/features.md`
- Changed:
  - Added board-local orb lookup helpers and presentation-only pre-drag hover forwarding from board orbs to the matching Elemental Mastery card.
  - Added separate hover-only mastery-card highlight nodes and a compact card detail panel with mastery level, base effect, per-orb value, modifier source names, and an explicit no-modifier empty state.
  - Kept hover state separate from active combat mastery replay feedback and cleared hover-only state on drag start, phase/turn changes, board mouse exit, and combat scene exit.
- Validation:
  - `git diff --check`, Godot MCP `get_project_info`, `view_script` checks, script load/scene instantiate probe, board orb lookup/highlight probe, hover-clear and replay-feedback preservation probe, card detail show/hide and content probes, and `play_scene current` passed.
  - Manual visual QA remains pending for all six real orb/card hover paths and overlap/readability. The final `get_godot_errors` read still reported the known stale CFR-02 enum reload diagnostics.

## [2026-05-05] code-change | CFR-09 Mastery Modifier Source Hover

- Source: `scripts/ui/player_loadout_hud.gd`, `docs/combat_feedback_revamp_tasks.md`, `docs/test_plan.md`, `wiki/features.md`
- Changed:
  - Hovering an Elemental Mastery card now lights equipment and relic tokens whose current modifier source affects that mastery/orb type.
  - The source highlight reuses the mastery detail source filtering, stays presentation-only, and clears on card hover exit or broader mastery-hover UI clears.
- Validation:
  - Godot MCP `view_script` and a focused hover-source probe passed after forcing the editor resource filesystem to rescan the externally edited HUD script. The probe confirmed Fire card hover lights only the matching equipment source, Gold card hover lights only the matching relic source, and hover exit clears both.

## [2026-05-05] docs-change | Milestone 10 Playtest Balance Scope

- Source: `todo.md`, `docs/test_plan.md`, `wiki/index.md`
- Changed:
  - Narrowed Milestone 10 to a short-term playtest balance pass focused on gold access, shop affordability, early survivability, content test access, and balance levers.
  - Added Milestone 11 as the meta progression foundation before the first playable build, with persistence and unlock/access scope.
  - Shifted first playable build packaging to Milestone 12.
- Notes:
  - This was a planning/documentation update only; no runtime validation was run.

## [2026-05-05] docs-change | Milestone 10 Balance Task Tracker

- Source: `docs/milestone_10_balance_tasks.md`, `todo.md`, `docs/test_plan.md`, `wiki/index.md`, `wiki/known-issues.md`
- Changed:
  - Added the M10 tracker with ordered tasks M10-01 through M10-07: Run Log plus balance-source inventory, untuned baseline runs, prototype balance levers, economy tuning, survivability tuning, content access, and closeout.
  - Added the M10 next-agent instruction template with explicit multi-agent workflow, Godot MCP validation, no-headless validation, and no-commit-unless-requested guardrails.
  - Linked the tracker from `todo.md`, `docs/test_plan.md`, and the wiki index, and replaced the generic balance-tuning known issue with a pointer to the M10 tracker and active source-owner caveat.
- Notes:
  - This was a documentation/tracker update only; no runtime validation was run.

## [2026-05-05] code-change | M10-01 Run Log And Balance Inventory

- Source: `scripts/core/run_state.gd`, `scripts/core/run_log_reporter.gd`, `scripts/combat/combat_player_controller.gd`, `docs/milestone_10_balance_tasks.md`, `docs/test_plan.md`, `wiki/features.md`, `wiki/file-map.md`, `wiki/known-issues.md`, `wiki/index.md`
- Changed:
  - Added passive Run Log capture in `RunState` for run start/end, fight start/end, turn results, shop open/actions/leave, and boss reward choice/skip.
  - Added JSON, text, and Markdown export helpers for baseline evidence.
  - Follow-up change writes JSON, Markdown, and text files automatically under gitignored `logs/` when a run finalizes, with last-export path/error metadata exposed through `RunState`.
  - Recorded the active balance-source inventory before tuning: board weights in `BoardGenerationSettings`, run gold and active encounters in `RunState`, combat gold formulas in `CombatStateMachine`, and shop pricing in `ContentRegistry` plus `ShopService`.
- Validation:
  - `git diff --check`, `git check-ignore -v logs/test.json`, Godot MCP `get_project_info`, `view_script`, focused load/scene instantiate probes, Run Log event/export probes, automatic file-export probe, boss reward choice probe, `play_scene main`, and final `get_godot_errors` passed.
  - Normal manual fight 1/shop 1 baseline exports remain for M10-02.

## [2026-05-05] code-change | Main Menu Run Log Toggle

- Source: `scripts/core/main_boot.gd`, `scenes/main.tscn`, `scripts/core/run_state.gd`, `docs/milestone_10_balance_tasks.md`, `docs/test_plan.md`, `wiki/features.md`, `wiki/file-map.md`, `wiki/index.md`
- Changed:
  - Added a main-menu `Generate Log` toggle that defaults off and persists through `user://matchatro_settings.cfg`.
  - Kept Run Log in-memory capture active, but gated automatic JSON/Markdown/text file export under `logs/` behind the toggle.
- Validation:
  - `git diff --check`, Godot MCP `view_script` for `run_state.gd` and `main_boot.gd`, focused toggle/export probe, `git status --short --ignored logs`, `play_scene main`, and final `get_godot_errors` passed.

## [2026-05-05] docs-change | Run Log Human Notes

- Source: `wiki/log-notes.md`, `wiki/index.md`, `docs/milestone_10_balance_tasks.md`, `docs/test_plan.md`
- Changed:
  - Moved player-skill context for the first two generated Run Logs out of M10-02 tracker/test-plan evidence.
  - Added [[log-notes]] to record that `run_1777938769_177353_2026-05-05t07_52_49` was a high-skill run and `run_1777940350_422781_2026-05-05t08_19_10` was an intentional new-player simulation.
  - Kept M10-02 baseline capture unstarted so M10-01 remains the active focus.
- Validation:
  - `git diff --check` passed.

## [2026-05-05] docs-change | M10-02 Untuned Baseline Runs

- Source: `docs/milestone_10_balance_tasks.md`, `docs/test_plan.md`, `todo.md`, `wiki/known-issues.md`, `logs/`
- Changed:
  - Marked M10-02 done after verifying 3 human-played untuned Run Logs with matching JSON, Markdown, and text exports.
  - Recorded baseline outcomes: high-skill defeat at level 2 boss, intentional new-player simulation defeat in level 1 fight 1, and a third defeat at level 3 enemy 1.
  - Documented mixed blocker categories before tuning: first-shop affordability, first-fight survivability/combat effectiveness, and level 2-3 enemy pressure.
  - Updated the next action to M10-03 prototype balance levers before direct economy or survivability tuning.
- Validation:
  - `git status --short --branch`, local Run Log inspection, `git diff --check`, Godot MCP `get_project_info`, and `get_godot_errors` were run. No automated probe runs were counted as baseline evidence.

## [2026-05-05] code-change | M10-03 Prototype Balance Levers

- Source: `scripts/core/run_state.gd`, `scripts/board/board_generation_settings.gd`, `scripts/content/content_registry.gd`, `scripts/shop/shop_service.gd`, `docs/milestone_10_balance_tasks.md`, `docs/test_plan.md`, `wiki/features.md`, `wiki/known-issues.md`
- Changed:
  - Added neutral temporary prototype balance levers for `starting_gold`, `gold_orb_spawn_weight_multiplier`, `shop_price_multiplier`, `reroll_cost_multiplier`, `enemy_hp_multiplier`, and `enemy_damage_multiplier`.
  - Kept active ownership authoritative: `RunState` applies starting gold and active encounter scaling, `BoardGenerationSettings` owns base orb weights, `ContentRegistry` exposes dictionary-backed pricing metadata, and `ShopService` applies offer/reroll price multipliers.
  - Deferred new debug/test access levers because existing debug commands cover forced setup and M10-02 evidence first needs economy/survivability tuning surfaces.
- Validation:
  - `git status --short --branch`, Godot MCP `get_project_info`, `view_script` checks, focused script-load checks, focused default/override lever probe, `get_godot_errors`, and `git diff --check` passed. The lever probe confirmed default parity and override effects for starting gold, enemy HP, enemy attack, gold normalized weight, shop price, and reroll cost.

## [2026-05-05] code-change | M10-04 Early Economy Tuning

- Source: `scripts/core/run_state.gd`, `docs/milestone_10_balance_tasks.md`, `docs/test_plan.md`, `wiki/features.md`, `wiki/known-issues.md`
- Changed:
  - Superseded an initial random-access economy pass before commit; the durable M10-04 direction became fixed fight base rewards plus matched-gold upside instead of boosted starting gold, Gold orb access, or discounted shop/reroll pricing.
  - Left enemy HP and damage multipliers at `1.0` for M10-05.
  - Recorded that the values are M10 playtest scaffolding, not final economy balance.
- Validation:
  - Superseded before final validation; see the later M10-04 fixed fight gold reward entry for committed validation evidence.

## [2026-05-05] docs-change | Victory Gold Overlay Bug

- Source: `wiki/known-issues.md`, user screenshot
- Changed:
  - Logged a screenshot-reported combat victory overlay bug where `GOLD GAINED +0` displayed even though the player expected `3` gold earned.
  - Marked the overlay feedback as unreliable for M10 playtest interpretation until investigated.
- Notes:
  - Documentation only; no runtime code, tuning values, or tracker status changed.

## [2026-05-05] code-change | M10-04 Fixed Fight Gold Reward

- Source: `scripts/core/run_state.gd`, `scripts/combat/combat_turn_logger.gd`, `scripts/combat/combat_player_controller.gd`, `scripts/shop/shop_service.gd`, `docs/milestone_10_balance_tasks.md`, `docs/test_plan.md`, `wiki/features.md`, `wiki/known-issues.md`
- Changed:
  - Shifted M10-04 early economy tuning from random-access boosts to fixed fight base rewards through the prototype balance lever surface.
  - Set new-run gold to `0`, kept Gold spawn/shop/reroll multipliers neutral, and added level 1/2/3 fight base rewards of `10/12/14`.
  - Updated the combat victory popup to show total fight gold as base plus matched gold, and guaranteed one exact 10-gold offer in the first level-1 shop.
  - Left enemy HP/damage at `1.0` for M10-05.
- Validation:
  - Godot MCP `get_project_info`, `view_script`, focused script reload checks, and focused reward/popup/shop affordability probes passed. `get_godot_errors` still included pre-existing stale enum diagnostics in the session log, but touched script reloads returned `0`.

## [2026-05-05] code-change | M10-05 Early Combat Survivability

- Source: `scripts/core/run_state.gd`, `docs/milestone_10_balance_tasks.md`, `docs/test_plan.md`, `wiki/features.md`, `wiki/known-issues.md`
- Changed:
  - Added level/type-scoped temporary survivability multipliers to the M10 prototype balance surface while keeping global enemy HP/damage multipliers neutral.
  - Set temporary level 1 normal HP/damage to `0.50/0.50`, level 1 boss to `0.60/0.65`, level 2 normal to `0.90/0.85`, level 2 boss to `1.0/0.90`, and level 3 normal/boss to `1.0/1.0`.
  - Recorded the level 1 target as forgiving enough for a player who can make at least one basic combo per turn.
  - Preserved enemy block values, intent order, player HP rules, combat math, resolver behavior, shop semantics, RunState routing, Run Log behavior, combat presentation timing, and the M10-04 fixed fight-gold reward/popup behavior.
- Validation:
  - `git status --short --branch`, Godot MCP `get_project_info`, `view_script`, focused encounter stat/economy guard/scoped override probes, `get_godot_errors`, and `git diff --check` passed. No normal human-played tuned Run Logs were captured; M10-07 should still gather tuned playtest logs before treating the values as accepted balance.

## [2026-05-05] qa-evidence | M10-05 Tuned Run Log

- Source: `logs/run_1777962841_273458_2026-05-05t14_34_01.json`, `docs/milestone_10_balance_tasks.md`, `docs/test_plan.md`, `wiki/known-issues.md`
- Observed:
  - Human-played tuned run cleared level 1 and reached the level 2 boss.
  - Fight outcomes: L1 enemy 1 victory in `4` turns, L1 enemy 2 victory in `21` turns, L1 boss victory in `11` turns, L2 enemy 1 victory in `15` turns, L2 enemy 2 victory in `7` turns, then L2 boss defeat on turn `3`.
  - The run opened five shops, filled equipment slots, bought a booster, claimed a mastery-card booster option, bought another mastery card, chose `Stalwart Mantle`, and ended with `7` gold.
- Notes:
  - Objective evidence supports the level 1 survivability target, but L1 enemy 2 took `21` turns at about `1.29` average combos per turn, so level 1 pacing remains worth watching.

## [2026-05-05] code-change | M10-05 Dungeon Identity Tuning

- Source: `scripts/core/run_state.gd`, `docs/milestone_10_balance_tasks.md`, `docs/test_plan.md`, `wiki/features.md`, `wiki/known-issues.md`
- Changed:
  - Kept Dungeon 1 forgiving on incoming damage while shifting its level 1 normal and boss intent cycles toward frequent block/defend, making it a damage check.
  - Shifted Dungeon 2 toward a defense check by raising level 2 damage multipliers to `1.0` normal and `1.10` boss, increasing attack frequency, and reducing block-heavy turns.
  - Preserved level 3 encounter stat signatures and M10-04 fight rewards `10/12/14`.
- Validation:
  - Godot MCP `view_script`, focused stat/identity probe with `ResourceLoader.CACHE_MODE_IGNORE`, `get_godot_errors`, and `git diff --check` passed. A normal `load(...)` probe observed stale cached script values before the cache-ignore rerun confirmed the current source.

## [2026-05-05] qa-evidence | M10-05 One-Combo Run

- Source: `logs/run_1777966488_296058_2026-05-05t15_34_48.json`, `docs/milestone_10_balance_tasks.md`, `docs/test_plan.md`, `wiki/known-issues.md`
- Observed:
  - One-combo-focused run cleared L1 enemy 1 in `12` turns and L1 enemy 2 in `9` turns.
  - The run died to Iron Gate on boss turn `17`, with Iron Gate still at `67/85 HP`.
  - The player accepted this as the intended target: one-combo play can clear the two Dungeon 1 normal fights, but the Dungeon 1 boss can defeat a player who does not improve damage output.
- Notes:
  - No runtime values changed for this evidence update.

## [2026-05-05] code-change | M10-05 Dungeon 3 Damage Check

- Source: `scripts/core/run_state.gd`, `logs/run_1777967813_853019_2026-05-05t15_56_53.json`, `docs/milestone_10_balance_tasks.md`, `docs/test_plan.md`, `wiki/features.md`, `wiki/known-issues.md`
- Changed:
  - Raised temporary level 3 normal HP/damage levers to `2.2/1.20`.
  - Raised temporary level 3 boss HP/damage levers to `2.60/1.30`.
  - Preserved Dungeon 1, Dungeon 2, combat math, RunState routing, passive Run Log behavior, and M10-04 fight-gold/shop rules.
- Evidence:
  - The high-effort run cleared Vault Executioner in `2` turns, Goldbound Keeper in `1` turn, and Prism Warden in `1` turn with `0` HP loss across Dungeon 3, so the last dungeon was too weak.
  - Godot MCP `get_project_info` and focused editor-script source probe confirmed the current temporary lever values. A follow-up tuned run should verify whether Dungeon 3 now holds up as the late damage check.

## [2026-05-05] decision | M10-05 Early Balance Accepted For Now

- Source: `logs/run_1777968781_770133_2026-05-05t16_13_01.json`, `logs/run_1777969048_434533_2026-05-05t16_17_28.json`, `docs/milestone_10_balance_tasks.md`, `docs/test_plan.md`, `wiki/known-issues.md`
- Decided:
  - Keep the current M10-05 early-balance values as acceptable prototype scaffolding.
  - Defer deeper combat rebalance until after Milestone 11 meta progression changes the player power curve.
- Evidence:
  - Run `run_1777968781_770133_2026-05-05t16_13_01` died at retuned Vault Executioner on turn `4`.
  - Run `run_1777969048_434533_2026-05-05t16_17_28` won, but retuned Dungeon 3 lasted `6`, `3`, and `4` turns with real HP damage taken.

## [2026-05-05] code-change | M10-06 Shop Access Run Log Detail

- Source: `scripts/core/run_state.gd`, `scripts/core/run_log_reporter.gd`, `docs/milestone_10_balance_tasks.md`, `docs/test_plan.md`, `wiki/features.md`
- Changed:
  - Expanded passive Run Log shop payloads with bounded offer snapshots for item and relic stock, including content ids, names, types, rarity, prices, affordability, available/sold-out state, booster presence, type counts, reroll state, and pending booster options.
  - Added shop action gold before/after, selected offer or booster option details, granted booster content, and shop before/after snapshots.
  - Added shop leave before/after snapshots so a bought same-level relic remains visible as sold out in exported logs.
  - Updated text and Markdown Run Log summaries so shop details are readable without manually parsing JSON.
- Validation:
  - Godot MCP `get_project_info`, `view_script`, focused first-shop/action/relic Run Log probes, `get_godot_errors`, and `git diff --check` ran. The final focused probes confirmed `shortsword`, booster, selected offer, text summary, and sold-out owned relic evidence in the log payloads; `get_godot_errors` still retained stale diagnostics from failed ad hoc probes.

## [2026-05-05] decision | M10-07 Playtest Baseline Closeout

- Source: `logs/run_1777968781_770133_2026-05-05t16_13_01.json`, `logs/run_1777969048_434533_2026-05-05t16_17_28.json`, `logs/run_1777973747_694854_2026-05-05t17_35_47.json`, `docs/milestone_10_balance_tasks.md`, `docs/test_plan.md`, `todo.md`, `wiki/features.md`, `wiki/known-issues.md`, `wiki/open-questions.md`
- Decided:
  - Milestone 10 creates a playable baseline for Milestone 11.
  - Do not treat M10 values as final balance.
  - Defer deeper combat/economy tuning, late full-slot friction review, and final shop-price/reroll decisions until after Milestone 11 meta progression changes the power curve.
- Evidence:
  - Untuned baseline first-shop access was weak or absent: first shops opened with `3`, no shop, and `0` gold across the three counted M10-02 baseline logs.
  - Tuned evidence includes one Dungeon 3 defeat, one full victory, and newest checked run `run_1777973747_694854_2026-05-05t17_35_47` reaching L3 enemy 2 after first-shop affordability, booster buys, equipment buys, and two boss relic rewards.
- Validation:
  - Godot MCP `get_project_info`, focused scene instantiate smoke for main/combat/shop/final summary, `play_scene main`, final `get_godot_errors`, local Run Log comparison, and `git diff --check` passed for the closeout documentation update.

## [2026-05-05] code-change | M11 Equipment Achievement Progression

- Source: `scripts/core/run_state.gd`, `scripts/run/meta_profile_state.gd`, `scripts/content/content_registry.gd`, `scripts/run/player_progression_service.gd`, `scripts/shop/shop_service.gd`, `scripts/core/main_boot.gd`, `scripts/flow/collection.gd`, `scripts/ui/achievement_toast.gd`, `scripts/flow/final_run_summary.gd`, `docs/test_plan.md`, `todo.md`, `wiki/features.md`, `wiki/file-map.md`
- Changed:
  - Added persistent Total Score and equipment unlock state through `MetaProfileState`, saved separately from per-run `RunState`.
  - Added Run Score tracking for non-sell gold sources and idempotent run-end banking into Total Score.
  - Replaced the active M11 equipment set with 5 families and Common/Uncommon/Rare variants, with Common default-unlocked and adjacent unlock costs of `100` and `300`.
  - Gated shop and booster equipment pools by unlocked variants while allowing lower unlocked rarities to keep rolling, and blocked equipping duplicate equipment families.
  - Enabled the main-menu Collection route, added the Collection scene, and added reusable bottom-right equipment unlock achievement toasts for victory unlocks and Score claims.
- Validation:
  - Godot MCP `get_project_info`, `view_script`, focused editor-script probes with `EditorFileSystem.scan()` and cache-ignore resource loads, `play_scene main`, `stop_running_scene`, final `get_godot_errors`, and `git diff --check` ran.
  - Focused probe confirmed 15 equipment variants, 5 families with 3 tiers each, content validation, family duplicate rejection, non-sell Run Score filtering, Common default unlocks, locked variant exclusion from shop pools, idempotent score banking, and scene instantiation for `main.tscn`, `collection.tscn`, `combat_player.tscn`, `shop_player.tscn`, and `final_run_summary.tscn`.
  - Manual QA remains pending for full-run Score visibility, victory unlock toast visibility, Collection claim interaction, and unlocked variant appearance in later shops.

## [2026-05-05] code-change | Default Player Profile

- Source: `scripts/core/run_state.gd`, `scripts/run/player_profile_state.gd`, `scripts/run/meta_profile_state.gd`, `scripts/flow/collection.gd`, `scenes/flow/collection.tscn`, `docs/test_plan.md`, `todo.md`, `wiki/features.md`, `wiki/file-map.md`
- Changed:
  - Added `PlayerProfileState` as the persistent default profile container for Milestone 11 meta progression.
  - `RunState` now saves the profile to `user://matchatro_profile.cfg`, migrates the previous flat `user://matchatro_meta_profile.cfg` shape into the default profile when needed, and keeps existing meta-profile APIs as compatibility wrappers.
  - Collection shows `Profile: Default Profile` and adds a `Reset Profile` action that resets profile/meta progression and recreates the default profile.
- Validation:
  - Godot MCP `get_project_info`, `view_script` for `player_profile_state.gd`, `run_state.gd`, and `collection.gd`, and focused editor-script profile probes ran.
  - Focused probe confirmed in-memory default profile creation, Total Score/unlocked-equipment save-load roundtrip, and Collection scene nodes for `ProfileLabel` and `ResetProfileButton`.

## [2026-05-05] code-change | Main Menu Profile Management

- Source: `scenes/main.tscn`, `scripts/core/main_boot.gd`, `scenes/flow/collection.tscn`, `scripts/flow/collection.gd`, `docs/test_plan.md`, `todo.md`, `wiki/features.md`, `wiki/file-map.md`
- Changed:
  - Moved profile management from Collection to the main-menu `Profile` footer button.
  - Added a main-menu Profile overlay showing the default profile name, Total Score, `Reset Profile`, and `Close`.
  - Removed profile label/reset controls from Collection so Collection only handles equipment rarity progression and Score claims.
- Validation:
  - Godot MCP `view_script` for `main_boot.gd` and `collection.gd` ran.
  - Focused scene probe confirmed `main.tscn` has `ProfileOverlay` and `ResetProfileButton`, and `collection.tscn` no longer has `ResetProfileButton`.
  - User QA passed for the profile-management move.

## [2026-05-05] milestone | M11 Manual QA Passed

- Source: `todo.md`, `docs/test_plan.md`, `wiki/log.md`
- Changed:
  - Marked Milestone 11 complete after user QA passed.
  - Recorded that follow-up fixes covered final-summary parser warnings, defeat unlock-toast leakage, and moving profile reset to the main-menu Profile overlay.
- Validation:
  - User QA passed.

## [2026-05-05] code-change | M12 Mobile Combat Readability Layout

- Source: `scripts/combat/combat_layout_manager.gd`, `scripts/ui/player_loadout_hud.gd`, `scripts/combat/combat_chrome_styler.gd`, `scripts/debug/mobile_combat_layout_probe.gd`, `docs/test_plan.md`, `todo.md`, `wiki/features.md`, `wiki/known-issues.md`
- Changed:
  - Reworked the mobile combat composition toward the provided reference: top bar, larger enemy stage/intent, slim timer, protected board, narrow mastery rail, and compact player footer.
  - Added the mobile combat layout probe for common portrait viewport overlap checks.
- Validation:
  - Godot MCP cache-ignore script reloads returned `0`, `combat_player.tscn` instantiated, `play_scene current` launched, and the probe reported `0` actionable overlaps for `1080x1920`, `1080x2400`, and `900x1600`.
  - Manual mobile visual/touch acceptance remains pending before the M12 readability gate is complete.

## [2026-05-05] code-change | M12 Reference-Faithful Mobile Combat UI Polish

- Source: `scenes/combat/combat_player.tscn`, `scripts/combat/combat_chrome_styler.gd`, `scripts/combat/combat_layout_manager.gd`, `scripts/combat/combat_player_controller.gd`, `scripts/ui/player_loadout_hud.gd`, `scripts/ui/visual_registry.gd`, `scripts/debug/mobile_combat_layout_probe.gd`, `resources/art/first_pass/derived/combat_ui/`, `tools/asset_tools/generate_combat_ui_chrome.py`, `docs/test_plan.md`, `todo.md`, `wiki/features.md`, `wiki/known-issues.md`
- Changed:
  - Added deterministic derived combat UI chrome for the mobile combat reference pass: backdrop/scrim, enemy panel, board frame, mastery rail, player HUD rail, loadout rail, block badge asset, timer track/marker, dividers, and corner ornaments.
  - Extended `VisualRegistry` with combat UI texture accessors and stable fallbacks.
  - Reworked combat scene chrome around texture-backed layers, including full-screen backdrop/scrim, large enemy stage, framed board, timer center marker, decorative dividers/corners, readable mastery rail, and structured bottom player HUD.
  - Extended the mobile layout probe to report primary zone rects, board size, overlap checks, and minimum readable zones for enemy intent, timer, board, mastery, HP, and loadout rails.
- Validation:
  - Godot MCP cache-ignore load/instantiate probes passed for layout, chrome, controller, shared HUD, visual registry, probe script, and `res://scenes/combat/combat_player.tscn`.
  - Godot MCP asset probe confirmed the new combat UI textures resolve through `VisualRegistry`; `play_scene current` launched, and a running-scene screenshot was captured/inspected at the current portrait runtime viewport.
  - Layout probe passed with `overlap_count=0`, empty actionable readability overlaps, and `readability_all_pass=true` for `1080x1920`, `1080x2400`, and `900x1600`; a board-local drag probe preserved intended cell selection.
  - Human screenshot review says the result is closer but still far from polished. Human reference approval and real touch QA remain pending before M12 export packaging resumes.

## [2026-05-05] code-change | M12 Combat UI Follow-Up Polish

- Source: `scripts/combat/combat_layout_manager.gd`, `scripts/combat/combat_chrome_styler.gd`, `scripts/ui/player_loadout_hud.gd`, `docs/test_plan.md`, `wiki/features.md`, `wiki/known-issues.md`
- Changed:
  - Enlarged enemy stage/intent presentation, separated enemy name from the HP bar, softened dividers/corners/frame borders, enlarged top-bar hit targets, and made compact HP/mastery/loadout rails more readable.
  - Kept the pass presentation-only; combat math, resolver behavior, RunState routing, drag coordinate handling, combat speed, replay timing, SFX, shop, and final summary behavior were not intentionally changed.
- Validation:
  - Godot MCP cache-ignore script loads and `combat_player.tscn` instantiate passed; layout probe reported `overlap_count=0`, actionable overlaps `0`, readability `7/7`, and enemy-name/HP-bar overlap `(0,0)` for `1080x1920`, `1080x2400`, and `900x1600`.
  - Godot MCP `play_scene current`, running scene-tree inspection, screenshot capture, and `git diff --check` passed. Final `get_godot_errors` still retained the stale session diagnostics already documented for the previous M12 combat UI pass; human visual approval remains pending.

## [2026-05-05] code-change | M12 Combat UI Restage

- Source: `scripts/combat/combat_layout_manager.gd`, `scripts/combat/combat_chrome_styler.gd`, `scripts/ui/player_loadout_hud.gd`, `docs/test_plan.md`, `wiki/features.md`, `wiki/known-issues.md`
- Changed:
  - Restaged combat toward the reference RPG hierarchy with a taller ornate header, deeper enemy banner, decorative READY divider, restored larger board, `MASTERY` rail, compact HP/relic panel, and split equipment/consumable rails.
  - Kept the pass presentation-only; combat math, resolver behavior, RunState routing, drag coordinate handling, combat speed, replay timing, and SFX were not intentionally changed.
- Validation:
  - `git diff --check`, cache-ignore script/scene loads, and `combat_player.tscn` instantiate passed with key combat/HUD nodes present.
  - Mobile layout probe passed for `1080x1920`, `1080x2400`, and `900x1600` with `overlap_count=0`, actionable readability overlaps `0`, and readability `7/7`; default board surface is about `643x772`.
  - Godot MCP `play_scene current`, running scene-tree inspection, and screenshot capture passed. Final `get_godot_errors` still retained stale session diagnostics from earlier probe attempts; human visual approval and real touch QA remain pending.

## [2026-05-05] code-change | M12 Combat UI Focused Review Pass

- Source: `scripts/combat/combat_layout_manager.gd`, `scripts/combat/combat_chrome_styler.gd`, `scripts/ui/player_loadout_hud.gd`, `docs/test_plan.md`, `wiki/features.md`, `wiki/known-issues.md`
- Changed:
  - Enlarged the perceived enemy encounter crop, integrated intent/block into the banner, reduced the READY fill visual, strengthened board bevel contrast, enlarged the `MASTERY` strip, and added empty relic placeholders for no-relic combat starts.
  - Kept the pass presentation-only with no intentional combat math, resolver, routing, drag coordinate, combat speed, replay timing, or SFX changes.
- Validation:
  - `git diff --check`, cache-ignore script/scene loads, and `combat_player.tscn` instantiate passed.
  - Mobile layout probe passed for `1080x1920`, `1080x2400`, and `900x1600` with `overlap_count=0`, actionable readability overlaps `0`, and readability `7/7`.
  - Godot MCP `play_scene current`, running screenshot capture, and `get_godot_errors` review completed. Stale session diagnostics remain in the Godot error buffer; human visual approval remains pending.

## [2026-05-06] code-change | M12 Combat UI Structural Correction

- Source: `scripts/combat/combat_layout_manager.gd`, `scripts/combat/combat_chrome_styler.gd`, `scripts/combat/combat_player_controller.gd`, `scripts/ui/player_loadout_hud.gd`, `docs/test_plan.md`, `wiki/features.md`, `wiki/known-issues.md`
- Changed:
  - Reworked the rejected compact/decorated surfaces structurally: enemy banner now uses a full-width backdrop plus separate foreground enemy layer, READY hides the fill at rest and reads as a decorative divider, `MASTERY` uses a broader strip with subtler per-orb segments, relic placeholders sit under player HP/vitals, and the footer is equipment plus consumables only.
  - Kept the pass presentation-only with no intentional combat math, resolver, routing, drag coordinate, combat speed, replay timing, or SFX changes.
- Validation:
  - `git diff --check`, cache-ignore combat script loads, and `combat_player.tscn` instantiate passed.
  - Mobile layout probe passed for `1080x1920`, `1080x2400`, and `900x1600` with `overlap_count=0`, actionable readability overlaps `0`, and readability `7/7`.
  - Godot MCP `play_scene current`, running scene-tree inspection, screenshot capture, and `get_godot_errors` review completed. The screenshot is structurally closer but not manually accepted; enemy foreground scale/source-art quality and real touch/device QA remain pending. Stale session diagnostics remain in the Godot error buffer.

## [2026-05-06] code-change | M12 Enemy Banner Composition Follow-Up

- Source: `scripts/combat/combat_layout_manager.gd`, `scripts/combat/combat_chrome_styler.gd`, `scripts/combat/combat_player_controller.gd`, `docs/test_plan.md`, `wiki/known-issues.md`
- Changed:
  - Rebuilt the enemy banner composition so the cave backdrop fills the full banner, the enemy is a large clipped foreground layer, the name/HP/HP bar cluster sits inside the lower-left banner, and the intent badge remains integrated on the right.
  - Fixed the follow-up containment regression by clipping enemy art to the banner so the header, READY divider, and board stay visible.
- Validation:
  - `git diff --check`, `combat_player.tscn` instantiate, and the mobile layout probe passed for `1080x1920`, `1080x2400`, and `900x1600` with `overlap_count=0`, actionable readability overlaps `0`, and readability `7/7`.
  - Godot MCP `play_scene current`, running screenshot capture, and `get_godot_errors` review completed. Stale session diagnostics remain in the Godot error buffer; final visual approval and real touch/device QA remain pending.

## [2026-05-06] code-change | M12 Combat UI Refinement Pass

- Source: `scripts/combat/combat_layout_manager.gd`, `scripts/combat/combat_chrome_styler.gd`, `scripts/combat/combat_player_controller.gd`, `scripts/ui/player_loadout_hud.gd`, `docs/test_plan.md`, `wiki/known-issues.md`
- Changed:
  - Refined the enemy intent module into a smaller right-side block with clearer title/value/detail hierarchy, cleaned the lower-left enemy name/HP scrim block, enlarged `MASTERY` readability, added a visible `RELICS` label with larger relic placeholders, and slightly expanded footer slot/label treatment.
  - Kept board/gems, READY divider direction, top header structure, combat math, resolver behavior, routing, drag coordinates, combat speed, replay timing, and SFX unchanged.
- Validation:
  - `git diff --check`, `combat_player.tscn` instantiate, and the mobile layout probe passed for `1080x1920`, `1080x2400`, and `900x1600` with `overlap_count=0`, actionable readability overlaps `0`, and readability `7/7`.
  - Godot MCP `play_scene current`, running node inspection, screenshot capture, and `get_godot_errors` review completed. Stale session diagnostics remain in the Godot error buffer; final visual approval and real touch/device QA remain pending.

## [2026-05-06] code-change | M12 Constrained HUD Refinement

- Source: `scripts/combat/combat_layout_manager.gd`, `scripts/combat/combat_chrome_styler.gd`, `scripts/combat/combat_player_controller.gd`, `scripts/ui/player_loadout_hud.gd`, `docs/test_plan.md`, `wiki/known-issues.md`
- Changed:
  - Kept board/gems, READY divider, top header, and screen order unchanged while refining intent padding/readability, player HUD height/portrait/relic spacing, mastery icon/text sizing, and footer slot centering/padding.
  - Preserved the presentation-only boundary: no combat math, resolver, routing, drag coordinate, combat speed, replay timing, or SFX changes were intentional.
- Validation:
  - `git diff --check`, `combat_player.tscn` instantiate, and the mobile layout probe passed for `1080x1920`, `1080x2400`, and `900x1600` with `overlap_count=0`, actionable readability overlaps `0`, and readability `7/7`.
  - Godot MCP `play_scene current`, running node inspection, screenshot capture, and `get_godot_errors` review completed. Stale session diagnostics remain in the Godot error buffer; final visual approval and real touch/device QA remain pending.

## [2026-05-06] code-change | M12 Static Enemy Image Revert

- Source: `scripts/combat/combat_layout_manager.gd`, `scripts/combat/combat_chrome_styler.gd`, `scripts/combat/combat_player_controller.gd`, `scripts/ui/visual_registry.gd`, `scripts/ui/player_loadout_hud.gd`, `docs/test_plan.md`, `wiki/features.md`, `wiki/known-issues.md`
- Changed:
  - Kept the generated dungeon background and single generated foreground enemy image, then removed the runtime spritesheet-backed enemy path after the temporary goblin animation experiment was rejected.
  - Preserved the presentation-only boundary: no combat math, resolver, routing, drag coordinate, combat speed, replay timing, SFX, shop, RunState, or final-summary changes were intentional.
- Validation:
  - `git diff --check` passed, runtime searches found no active `EnemySpriteView` / `EnemyAnimatedSprite` / spritesheet lookup references, and Godot MCP `play_scene current` launched `res://scenes/combat/combat_player.tscn`.
  - Running scene-tree inspection confirmed `EnemyStageBackdrop` plus visible `EnemyPortrait`, no animated enemy nodes, hidden intent prose, and compact intent bubble visibility. Screenshot review scored the final static enemy image pass 9/10. `get_godot_errors` retained the same two stale enum reload diagnostics.

## [2026-05-06] code-change | M12 Board Cell Border Reduction

- Source: `scripts/combat/combat_chrome_styler.gd`, `docs/test_plan.md`, `wiki/features.md`
- Changed:
  - Removed the repeated ornate slot-frame texture from individual combat board cells so each orb no longer sits inside its own decorative border.
  - Preserved the outer board frame, dark cell bed, orb textures, board size, combat math, resolver behavior, routing, drag coordinates, combat speed, replay timing, and SFX.
- Validation:
  - `git diff --check` passed.
  - Godot MCP `view_script`, `play_scene current`, running screenshot capture, and `get_godot_errors` review completed. The screenshot showed the per-cell ornate borders removed; `get_godot_errors` retained the same two stale enum reload diagnostics.

## [2026-05-06] code-change | M12 Empty Relic Placeholder Cleanup

- Source: `scripts/ui/player_loadout_hud.gd`, `docs/test_plan.md`, `wiki/features.md`
- Changed:
  - Removed empty bordered relic placeholder boxes when the player owns no relics.
  - Kept the `RELICS` label, owned relic icon rendering, relic overflow behavior, combat math, routing, drag coordinates, and timing unchanged.
- Validation:
  - `git diff --check` passed.
  - Godot MCP `view_script` loaded `player_loadout_hud.gd`; cache-ignore relic-row probe returned `empty_children=0` and `filled_children=1`; `play_scene current` and running screenshot capture confirmed the empty relic boxes are gone.

## [2026-05-06] code-change | M12 Consumable Rail Right Alignment

- Source: `scripts/ui/player_loadout_hud.gd`, `scripts/combat/combat_layout_manager.gd`, `docs/test_plan.md`, `wiki/features.md`
- Changed:
  - Moved the combat consumable slots and label to the right edge of the bottom loadout strip.
  - Preserved equipment slots, slot rendering, combat math, routing, drag coordinates, combat speed, replay timing, and SFX.
- Validation:
  - `git diff --check` passed.
  - Godot MCP `view_script` loaded the touched scripts; cache-ignore layout probe returned `overlap_count=0`, readability `true`, equipment rail at `x=36`, and consumable rail at `x=730`; `play_scene current` and screenshot capture confirmed the right-aligned consumable group.

## [2026-05-06] code-change | M12 Mastery Box Borders

- Source: `scripts/ui/player_loadout_hud.gd`, `docs/test_plan.md`, `wiki/features.md`
- Changed:
  - Reverted the outer combat `MASTERY` panel border.
  - Added subtle per-card 3D/beveled border and shadow styling to each mastery box.
  - Preserved combat math, routing, drag coordinates, combat speed, replay timing, and SFX.
- Validation:
  - `git diff --check` passed.
  - Godot MCP `view_script` loaded `player_loadout_hud.gd`; cache-ignore style probe confirmed the mastery panel is empty-styled and cards carry border/shadow styling; `play_scene current`, screenshot capture, and `get_godot_errors` review completed.

## [2026-05-06] code-change | M12 Mastery Label And Detail Readability

- Source: `scripts/ui/player_loadout_hud.gd`, `docs/test_plan.md`, `wiki/features.md`
- Changed:
  - Removed visible name/level text from compact combat mastery cards so the row is icon-only.
  - Suppressed the native mastery icon tooltip text that duplicated `Fire Mastery` style hover labels.
  - Enlarged the mastery detail popover to `960 x 468` and increased title/effect/value/modifier font sizes for readability.
- Validation:
  - `git diff --check` passed.
  - Godot MCP `view_script` loaded `player_loadout_hud.gd`; cache-ignore probe confirmed six cards, no `MasteryLabel` or `MasteryLevel` nodes, empty icon tooltip text, and the enlarged detail bubble size; `play_scene current`, screenshot capture, and `get_godot_errors` review completed.

## [2026-05-06] code-change | M12 Shop Mobile Readability

- Source: `scripts/flow/shop_player.gd`, `docs/test_plan.md`, `wiki/features.md`, `wiki/known-issues.md`
- Changed:
  - Shortened the merchant stage, enlarged the stock panel/cards, relic card, and action row, and increased item names, framed art, descriptions, price badges, and disabled-state labels for mobile portrait readability.
  - Added a shop-only `PlayerLoadoutHud` layout override so the action row and shared HUD sit in a continuous portrait flow with a 30px design-space gap.
  - Kept shop economy, content pools, transaction handlers, RunState routing, shared HUD API, booster flow, and sell popover behavior unchanged.
- Validation:
  - `git diff --check` passed.
  - Godot MCP `view_script` loaded `shop_player.gd`; source-parse layout probe confirmed `bottom_gap_before_hud=30`, `action_row_overlaps_hud=false`, `stock_total_width=1004`, `stock_content_width=1004`, and `stock_fits=true`; `get_godot_errors` reported no session errors.
  - Active in-run shop screenshot review and target-device visual acceptance remain pending.

## [2026-05-06] docs | Scene Structure Refactor Plan

- Source: `docs/scene_structure_refactor_plan.md`, `docs/system_architecture.md`, `wiki/architecture.md`, `wiki/file-map.md`, `wiki/known-issues.md`
- Changed:
  - Documented the current `scenes/` inventory, empty folder mismatch, and proposed final taxonomy separating app/screen scenes, reusable components, and development previews.
  - Recorded the Player HUD combat/shop visual drift as an architecture regression from the intended shared partial/component contract.
  - Added SOLID ownership rules and stepwise refactor tasks for shared HUD scene extraction, combat/shop HUD identity restoration, scene moves, empty folder cleanup, and scene contract validation.
- Validation:
  - Documentation-only change. Current scene inventory was checked with PowerShell; no files were moved and no runtime behavior was changed.

## [2026-05-06] code-change | Transition Rollback Nested State

- Source: `scripts/core/run_state.gd`, `docs/test_plan.md`, `wiki/known-issues.md`
- Changed:
  - Extended `RunState` transition snapshots to capture and restore nested player combat state, progression state, and shop state.
  - Preserved Start Run and final-summary New Run prepare-before-commit behavior while making attach-failure recovery restore HP, armor, timer, inventory, mastery, relics, active effects, shop data, and shop offer sequence.
- Validation:
  - `git diff --check` passed.
  - Godot MCP `view_script` loaded `run_state.gd`; focused cache-ignore rollback probe confirmed before/after state equality after a forced reset; `play_scene main`, running scene-tree smoke, `stop_running_scene`, and `get_godot_errors` completed with `Session has no errors`.

## [2026-05-06] code-change | FlowTrace And Callback Cleanup

- Source: `scripts/core/run_state.gd`, `scripts/ui/player_loadout_hud.gd`, `scripts/combat/combat_player_controller.gd`, `scripts/core/main_boot.gd`, `scripts/flow/collection.gd`, `scripts/flow/final_run_summary.gd`, `scripts/flow/shop_player.gd`, `docs/architecture_review_tasks.md`, `docs/test_plan.md`, `wiki/known-issues.md`, `wiki/architecture.md`, `wiki/file-map.md`
- Changed:
  - Capped retained FlowTrace route state at 50 routes and added `flow_trace_debug_snapshot()` for focused probes.
  - Added transition-generation stale rollback protection around prepared-scene post-ready checks and run mutation boundaries.
  - Added `PlayerLoadoutHud` bound-section lifecycle cleanup for intent preview tweens.
  - Replaced low-risk string-based `Callable(self, "...")` bindings with direct callable references and removed stable transition API `has_method(...)` guards.
- Validation:
  - `git diff --check` passed.
  - Godot MCP `view_script` loaded all touched runtime scripts; focused FlowTrace cap/generation, scene instantiate, HUD lifecycle, and AR-01 combat result-envelope probes passed.
  - `play_scene main`, `stop_running_scene`, and final `get_godot_errors` completed with `Session has no errors`.

## [2026-05-06] code-change | Shared Player HUD Scene

- Source: `scenes/ui/player_hud.tscn`, `scenes/combat/combat_player.tscn`, `scripts/combat/combat_player_controller.gd`, `scripts/flow/shop_player.gd`, `wiki/file-map.md`, `wiki/features.md`
- Changed:
  - Promoted the combat PlayerHudSection tree into reusable `scenes/ui/player_hud.tscn`.
  - Updated combat to instance the shared HUD scene and resolve HUD internals through the shared root.
  - Updated shop to instantiate the same shared HUD scene instead of dynamically building a parallel HUD tree.
  - Corrected the shared HUD binding so shop and combat bind the same full node set and use one internal PlayerHUD layout; shop only positions the whole HUD section.
  - Documented the user-confirmed intended behavior in `docs/test_plan.md`, `wiki/features.md`, `wiki/file-map.md`, and `wiki/known-issues.md`.
  - Added `scripts/debug/player_hud_contract_probe.gd` to guard the shared PlayerHUD scene, combat/shop binding keys, and shop whole-section-only layout override against regression.
- Validation:
  - Godot MCP `view_script` and `scripts/debug/player_hud_contract_probe.gd` returned `{ "status": "ok", "failures": [] }`.
  - Godot MCP focused probe confirmed `player_hud.tscn`, `combat_player.tscn`, and `shop_player.tscn` load, and that combat instances the shared HUD scene with required HUD nodes present.
  - Godot MCP `play_scene current` for combat reached first usable frame with no new runtime errors.
  - Godot MCP `play_scene current` for shop created and bound the shared HUD before redirecting to main menu when no active run existed; no new runtime errors were reported. Existing stale enum reload warnings remained in the editor session.

## [2026-05-06] code-change | Shop Readability Revamp

- Source: `scripts/flow/shop_player.gd`, `scripts/ui/player_loadout_hud.gd`, `docs/test_plan.md`, `wiki/features.md`, `wiki/known-issues.md`
- Changed:
  - Rebalanced the shop portrait layout around readability: shorter merchant stage, taller stock cards, a taller relic card, and explicit non-overlapping card bands for names, rarity/type labels, descriptions, disabled states, and prices.
  - Enlarged the shared `PlayerLoadoutHud` slot detail popover with larger title/description/sell typography, wider dynamic sizing, wrapped-description height estimation, and parent-bounded placement.
  - Preserved shop economy, content pools, transaction handlers, RunState routing, booster flow, and the shared `scenes/ui/player_hud.tscn` contract.
- Validation:
  - Multi-agent review initially rated the partial pass `6.5/10`; the worker fixed the reported stock-row overflow, disabled-label overlap, and insufficient popover readability.
  - Godot MCP `get_project_info`, `view_script` for `shop_player.gd` and `player_loadout_hud.gd`, focused layout/readability probe, `play_scene current`, `stop_running_scene`, and `get_godot_errors` passed.
  - Final probe confirmed `stock_total_width=1016`, `stock_content_width=1020`, `stock_slack=4`, `stock_fits=true`, `offer_desc_state_gap=6`, `offer_state_price_gap=6`, `bottom_gap_before_hud=26`, and `action_row_overlaps_hud=false`.
  - Active in-run shop screenshot review and target-device visual acceptance remain pending.

## [2026-05-06] bug-fix | Shop Header Load Crash

- Source: `scripts/flow/shop_player.gd`, `scripts/core/run_state.gd`, `docs/test_plan.md`
- Changed:
  - Fixed the shop header progress label to use `RunState.current_shop_ordinal_in_level()` instead of the nonexistent `RunState.fight_index` property.
  - Preserved the readable `Dungeon X-Y Shop` header introduced by the shop readability revamp while staying on the existing RunState public API.
- Validation:
  - Godot MCP `view_script` reloaded `scripts/flow/shop_player.gd`.
  - Godot MCP `play_scene current` loaded `res://scenes/flow/shop_player.tscn` and redirected cleanly when no active run existed.
  - Godot MCP `get_godot_errors` reported `Session has no errors` after rerun; active-run shop screenshot review remains pending.
