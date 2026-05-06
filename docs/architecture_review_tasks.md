# Architecture Review Task Tracker

Purpose: track architecture-review follow-up work with explicit status, progress, blockers, validation gates, and documentation impact. This is the entry point for architecture-maintenance tasks before Milestone 10 balance closure.

Status values: `not started`, `in progress`, `blocked`, `done`, `deferred`.

## AR-01: Baseline Regression Harness

- Status: `done`
- Owner/scope: Regression checklist and Godot MCP probe workflow for board resolver, combat state machine, shop service, RunState routing, audio loading, and shared HUD selection.
- Progress: 2026-05-03 baseline evidence captured in `docs/test_plan.md` for branch/worktree state, `git diff --check`, `get_project_info`, `get_godot_errors`, main/combat/board-debug/shop scene smokes, user runtime route timings for `Start Run -> Combat`, `Combat -> Shop`, and `Shop -> Combat`, board resolver known cases, combat state machine result envelope, shop service buy/reroll/sell/booster basics, RunState route invariants, audio stream loading, and minimal `PlayerLoadoutHud` selection/popover behavior.
- Blockers: None for AR-01 baseline capture. Remaining manual QA items such as texture-map visual pop-in, live HUD sell flow, overlap checks, and integer-division warning cleanup stay tracked outside AR-01 completion.
- Next action: Use the retained AR-01 harness as the pre-refactor comparison point for AR-02 and later architecture-touching batches.
- Validation: Static checks pass; Godot MCP checks cover `res://scenes/main.tscn`, `res://scenes/combat/combat_player.tscn`, `res://scenes/combat/board_debug.tscn`, and `res://scenes/flow/shop_player.tscn`; focused probes record expected result envelopes for deterministic systems.
- Docs/wiki impact: `docs/test_plan.md`, `wiki/file-map.md`, `wiki/setup.md`, `wiki/known-issues.md`, and `wiki/log.md` updated for the retained feature-flagged AR-01 probe and captured baseline.

## AR-02: Low-Risk Bug Fixes

- Status: `done`
- Owner/scope: Small confirmed issues such as `EnemyState.get_current_intent()` mutation, main-menu music polling after success, noisy audio diagnostics, and await/transition guards.
- Progress: 2026-05-03 completed the low-risk batch. `EnemyState.get_current_intent()` returns a duplicated intent snapshot before adding the derived `index`, keeping the caller contract unchanged while making the read API non-mutating by construction. The main-menu music retry poll stops after successful desktop playback or Android/template `AudioManager` routing while preserving retry behavior for failed setup. Verbose `AudioManager` music diagnostics are gated behind `debug/audio_diagnostics_enabled=false` by default. Run-flow entry/exit controls now have local duplicate-transition guards for Start Run, player-shop Continue/Menu, legacy boss-reward Skip/Continue, and legacy shop Skip/Next/Menu; player-shop and legacy reward/shop advance actions now check failed `RunState` transition results before routing.
- Blockers: None for AR-02 completion. Known unsourced Godot integer-division reload warnings remain tracked outside this low-risk batch.
- Next action: Move to AR-03 shared WAV/audio utility extraction or AR-04 shop/input safety after choosing the next architecture-review batch.
- Validation: Intent snapshot probe passed; main scene smoke confirmed desktop `MainMenuMusicPlayer` playback; focused audio setting probe confirmed diagnostics are opt-in; transition scene instantiate probes passed for `res://scenes/main.tscn`, `res://scenes/flow/shop_player.tscn`, `res://scenes/flow/boss_relic_reward.tscn`, and `res://scenes/flow/shop_placeholder.tscn`; retained AR-01 combat result-envelope probe still matched the documented baseline. Fresh `get_godot_errors` returned no session errors after script/instantiate checks; after main scene smoke it still reported the known unsourced integer-division reload warnings.
- Docs/wiki impact: `docs/test_plan.md`, `wiki/features.md`, and `wiki/log.md` updated for the completed AR-02 batch.

## AR-03: Shared WAV/Audio Utility Extraction

- Status: `done`
- Owner/scope: Shared WAV parsing, frame-count, and loop configuration logic currently duplicated between `scripts/core/audio_manager.gd` and `scripts/core/main_boot.gd`.
- Progress: 2026-05-03 completed the extraction by adding `scripts/core/audio_stream_loader.gd` as the shared helper for file byte loading, signed PCM16 WAV parsing, imported `AudioStream` loop configuration, WAV loop bounds, and source-header frame counts. `scripts/core/audio_manager.gd` and `scripts/core/main_boot.gd` now call the shared loader instead of carrying duplicate WAV helper implementations. Generated music/SFX remains owned by `AudioManager`, and the AR-02 desktop shop-to-main-menu audio handoff remains unchanged: desktop main menu stops shared `AudioManager` music before local `MainMenuMusicPlayer` playback, while Android/template menu music still routes through `AudioManager`.
- Blockers: None for AR-03 completion. Android/on-device listening and loop-length acceptance remains manual unless explicitly retested on hardware.
- Next action: Move to AR-04 shop/input safety or another architecture-review batch.
- Validation: Pre-change and post-change Godot MCP audio probes matched for menu/combat/shop WAV stream class, volume, data bytes, and loop ends; generated `swap` SFX still builds; the direct main-menu music loader returns the same WAV data and loop end; the focused shared-music stop probe still reports `before_key=shop before_playing=true after_key= after_playing=false`; retained AR-01 combat result-envelope probe still matched baseline; `play_scene main` launched with desktop `MainMenuMusicPlayer` playback and `get_godot_errors` reported no session errors.
- Docs/wiki impact: `docs/test_plan.md`, `wiki/features.md`, `wiki/file-map.md`, and `wiki/log.md` updated for the new shared audio loader ownership.

## AR-04: Shop/Input Safety

- Status: `done`
- Owner/scope: `scripts/flow/shop_player.gd`, `scripts/shop/shop_service.gd`, and shared `scripts/ui/player_loadout_hud.gd` interaction behavior.
- Progress: 2026-05-03 completed the shop/input safety batch. `PlayerLoadoutHud` hover now previews item details without mutating committed equipment or consumable selection; Sell is shown only when the hovered equipment/consumable slot matches the clicked selected slot. `shop_player.gd` now routes touch outside-dismissal through the same shared HUD focus handler as mouse clicks and adds a same-frame action guard around buy, relic buy, reroll, sell, booster pick, and booster skip handlers so one input frame cannot execute duplicate shop transactions. Manual QA then found the first outside-dismiss route still failed on PC and Android because handled UI events did not reach `_unhandled_input`; the shop now performs the dismissal check in `_input` without marking the event handled. A second manual follow-up found the popover closed but selected chrome stayed active; outside-dismiss now clears inventory focus and refreshes the shop UI so slot selection re-renders cleared.
- Blockers: None for the AR-04 code batch. Live visual overlap checks, texture-map pop-in, and Android listening remain manual QA unless explicitly retested.
- Next action: Move to the next selected architecture-review batch after any desired manual shop/touch QA.
- Validation: Godot MCP `view_script` checks passed for `res://scripts/ui/player_loadout_hud.gd` and `res://scripts/flow/shop_player.gd`; focused editor-script probes confirmed hover preserves committed selection through hover enter/exit, click selection still commits, Sell appears only for the selected hovered slot, outside-click focus dismissal clears selection, same-frame shop action calls are guarded, and `res://scenes/flow/shop_player.tscn` instantiates. Follow-up source-shape and scene instantiate probes passed after moving outside-dismissal to `_input`; `view_script` and `get_godot_errors` passed after the focus-clear/refresh follow-up. Final `get_godot_errors` reported no session errors. User manual QA confirmed the outside-dismissal and visual deselection fixes on PC and Android.
- Docs/wiki impact: `docs/test_plan.md`, `todo.md`, `wiki/features.md`, `wiki/known-issues.md`, and `wiki/log.md` updated for the completed AR-04 batch.

## AR-05: Combat Controller First Split

- Status: `done`
- Owner/scope: First behavior-preserving extraction from `scripts/combat/combat_player_controller.gd`; `scripts/combat/combat_outcome_overlay.gd` now owns the combat outcome overlay presentation boundary for standard victory/defeat cards, boss reward card controls, scrim layering, and overlay layout.
- Progress: 2026-05-03 completed the first split. `combat_player_controller.gd` still owns combat math, resolve presentation timing, RunState victory/defeat/boss-reward routing, audio calls, scene transitions, input phase changes, debug console commands, and `/skip`; `CombatOutcomeOverlay` owns only outcome/boss-reward UI state, card content/layout, visibility, and helper text wrapping.
- Blockers: None for AR-05 completion. Broader combat presentation extraction remains deferred to AR-06 and still needs visual regression checks before touching resolver replay timing.
- Next action: Move to AR-06 only after choosing a presentation-only boundary that preserves the accepted resolve order.
- Validation: Godot MCP `view_script` checks passed for `res://scripts/combat/combat_outcome_overlay.gd` and `res://scripts/combat/combat_player_controller.gd`; focused editor-script probes confirmed helper load/methods, `res://scenes/combat/combat_player.tscn` instantiate, outcome node presence, helper boss-reward controls/scrim/layout state, standard summary state, boss reward state, hide state, and text wrapping. Retained AR-01 combat result-envelope probe still matched baseline values. Final `get_godot_errors` reported no session errors. User manual QA confirmed normal victory continue, boss reward claim/skip, defeat Main Menu, final-boss summary, debug console commands, and resolve presentation order remained good.
- Docs/wiki impact: `docs/test_plan.md`, `todo.md`, `wiki/architecture.md`, `wiki/file-map.md`, and `wiki/log.md` updated for the new helper ownership.

## AR-06: Combat Presentation Split

- Status: `done`
- Owner/scope: `scripts/combat/combat_resolve_presenter.gd` now owns the board-space resolve replay presentation boundary: match-group presentation sorting, match flash waits, clear/gravity/refill animation timing, visual board commits, clear burst spawning, combo popup lifecycle, and `combat_speed` duration/wait behavior. `scripts/combat/combat_player_controller.gd` still owns drag/input lifecycle, resolver simulation, combat math, mastery preview value calculation and HUD feedback decisions, RunState routing, outcome overlay routing, audio routing callbacks, scene transitions, debug console, and `/skip`.
- Progress: 2026-05-03 completed the presentation split with a callback boundary from the controller into `CombatResolvePresenter`. The accepted visible ordering is preserved by keeping the replay sequence as match flash, clear animation, visual clear commit, `combo_tick` trace, combo popup/mastery preview, gravity animation/commit, refill animation/commit. AR-08 cleanup candidates were left untouched.
- Blockers: None for the AR-06 code batch. Manual visual QA on Android passed for the AR-06 combat presentation checks; broader desktop/mobile overlap and deferred orb texture-map pop-in review remain useful outside this batch.
- Next action: Move to AR-07 or another selected architecture-review batch.
- Validation: Godot MCP `view_script` checks passed for `res://scripts/combat/combat_resolve_presenter.gd` and `res://scripts/combat/combat_player_controller.gd`; `res://scenes/combat/combat_player.tscn` instantiated with board and outcome nodes; retained AR-01 combat result-envelope probe still matched baseline values; `play_scene main` launched successfully with no runtime errors; final `get_godot_errors` reported no session errors. A first attempt at a focused async presenter-order editor probe hit an MCP tool-script parse limitation before execution. User manual QA on the installed Android build confirmed AR-06 presentation behavior works.
- Docs/wiki impact: `docs/test_plan.md`, `todo.md`, `wiki/architecture.md`, `wiki/features.md`, `wiki/file-map.md`, and `wiki/log.md` updated for the new helper ownership.

## AR-07: RunState/Data Contract Roadmap

- Status: `done`
- Owner/scope: `scripts/core/run_state.gd`, `scripts/content/content_registry.gd`, `docs/system_architecture.md`, and future content data format.
- Progress: 2026-05-03 completed the AR-07 roadmap pass. The prototype source of truth is now documented as dictionary-backed `ContentRegistry` content for this phase, with Resource or JSON migration deferred behind the existing registry read API. `ContentRegistry.content_contract_snapshot()` records current collection fields, validation ownership, shop pool/pricing ownership, and the future migration boundary. `RunState.run_contract_snapshot()` records run-owned persistence/routing fields, scene route constants, level sequence, public transition/action APIs, and the content dependency boundary. Single-item content getters now return duplicated dictionaries like list APIs, so caller mutation cannot alter the registry index.
- Blockers: None for AR-07 completion. Actual `.tres`, JSON, or external content migration is intentionally deferred to a future scoped task.
- Next action: Move to AR-08 cleanup/dead-code validation only when ready, keeping cleanup separate from content migration.
- Validation: Godot MCP `view_script` checks passed for `res://scripts/core/run_state.gd` and `res://scripts/content/content_registry.gd`; focused content contract probe confirmed validation `[]`, expected content counts, contract snapshots, and non-mutating single-item getters; RunState route invariant probe preserved AR-01 route shapes; retained AR-01 combat result-envelope probe still matched baseline; scene instantiate checks passed for main, combat, board-debug, and shop; final `get_godot_errors` reported no session errors; `git diff --check` passed.
- Docs/wiki impact: `docs/system_architecture.md`, `docs/test_plan.md`, `todo.md`, `wiki/architecture.md`, `wiki/file-map.md`, `wiki/known-issues.md`, and `wiki/log.md` updated for the AR-07 contract boundary.

## AR-08: Cleanup/Dead-Code Validation

- Status: `done`
- Owner/scope: Confirmed-unused symbols and stale placeholder/fallback surfaces such as `base_orb_values`, `PLAYER_EFFECT_ORDER`, summary helpers, and legacy placeholder scenes.
- Progress: 2026-05-03 completed cleanup in two passes. First removed `PlayerState.base_orb_values`, the unused `CombatStateMachine.PLAYER_EFFECT_ORDER` constant, and unused legacy string-format helpers. Follow-up cleanup renamed the final victory surface from `run_summary_placeholder` to `final_run_summary`, removed the legacy boss relic reward scene/script after boss rewards moved fully into the combat victory overlay, removed the legacy shop placeholder scene/script, and removed the board-debug scene/controller. Boss reward data APIs and the `boss_relic_reward` run step key remain because the combat overlay still uses them.
- Blockers: None for this cleanup batch. Historical validation notes still mention deleted debug/fallback surfaces as past evidence, but current validation should use `main.tscn`, `combat_player.tscn`, `shop_player.tscn`, `final_run_summary.tscn`, and focused editor-script probes.
- Next action: Move to the next architecture-review batch. If a replacement board-debug workflow is needed later, implement it as a new scoped debug tooling task rather than reviving the deleted scene.
- Validation: Godot MCP `view_script` passed for touched scripts; `get_godot_errors` reported no session errors; retained AR-01 combat result-envelope probe still matched baseline; RunState route probes preserved combat/shop/boss-reward/final-victory route shapes with final victory routing to `res://scenes/flow/final_run_summary.tscn`; defeat now also routes to `res://scenes/flow/final_run_summary.tscn` in defeat mode while reset/no-summary inactive state still routes to main; main, combat, shop, and final summary scenes instantiate/run as validation surfaces; deleted-scene reference searches are clean; `git diff --check` passed.
- Docs/wiki impact: `AGENTS.md`, `docs/architecture_review_tasks.md`, `docs/test_plan.md`, `todo.md`, `wiki/features.md`, `wiki/file-map.md`, `wiki/known-issues.md`, `wiki/setup.md`, and `wiki/log.md` updated for the completed cleanup and new validation surfaces.

## AR-09: Stability And Shared UI Utility Cleanup

- Status: `done`
- Owner/scope: Fix the confirmed post-AR-08 stability risks before larger architecture movement. Scope includes lifecycle-safe awaits in combat resolve presentation, bounded animation-drain behavior, duplicate-transition guards in final summary, main-menu failed-transition recovery, one untraced combat redirect, and the duplicated `_panel_style()` signature risk between player-facing flow scenes.
- Progress: 2026-05-03 completed the stability cleanup without changing combat math, resolver order, visible resolve order, combo/mastery timing, content data, audio priority, route semantics, debug commands, or `/skip`. `combat_player_controller.gd` now checks scene/board continuation after awaited resolve presentation and turn replay steps before committing final board state or routing outcomes. `CombatResolvePresenter` now checks timer owner, scene tree, and board-view validity after waits and before touching bound nodes, and the final animation drain exits on invalid lifecycle state or a bounded timeout/iteration cap. The combat wrong-step redirect now uses `RunState.flow_trace_change_scene(...)` instead of a bare deferred `change_scene_to_file`. `main_boot.gd` now checks Start Run transition results and restores the button/status state on failure. `final_run_summary.gd` now guards `New Run` and `Main Menu` actions with a single transition lock and disabled buttons while routing. `scripts/ui/ui_utils.gd` now owns the canonical `panel_style(fill, border, border_width := 2, radius := 6, margins := Vector4.ZERO)` helper used by `shop_player.gd` and `final_run_summary.gd`, preserving their previous border/radius/margin visuals while removing the signature mismatch.
- Out of scope:
  - Do not change combat math, accepted resolve order, combo/mastery feedback timing, content data shape, audio priority behavior, or broader controller ownership.
  - Do not migrate every `StyleBoxFlat` in `player_loadout_hud.gd`; this batch only fixes the duplicated helper-signature trap in flow scenes.
- Validation: `git status --short --branch` confirmed branch `codex/ar-09-stability-ui-cleanup` with the preserved uncommitted AR tracker edit plus AR-09 source/doc changes; `git diff --check` passed. Godot MCP `get_project_info` reported Godot `4.6.2-stable`; `view_script` passed for `combat_player_controller.gd`, `combat_resolve_presenter.gd`, `main_boot.gd`, `final_run_summary.gd`, `shop_player.gd`, and `ui_utils.gd`; `get_godot_errors` reported no session errors. Focused editor probes passed for scene instantiation of `main.tscn`, `combat_player.tscn`, and `final_run_summary.tscn`, and for canonical `UiUtils.panel_style(...)` border/radius/margin mapping. `play_scene main` launched with desktop `MainMenuMusicPlayer` playback and no session errors. User manual sanity QA on 2026-05-04 confirmed Start Run, combat resolve/cascade feel, combat routing, final-summary actions, shop regression, and visible panel styling are all good.
- Docs/wiki impact: `docs/test_plan.md`, `wiki/features.md`, `wiki/file-map.md`, `wiki/known-issues.md`, and `wiki/log.md` updated for the stability fixes and shared `UiUtils` ownership.

## AR-10: Combat Controller God-Object Refactor

- Status: `done`
- Owner/scope: Reduce `scripts/combat/combat_player_controller.gd` by extracting the lowest-risk remaining responsibilities after AR-09 stability cleanup. First extraction target is debug console ownership plus turn-log formatting, because those areas are large, mostly isolated, and less coupled to combat math or resolve timing than input, layout, VFX, HUD sync, or routing.
- Progress: 2026-05-04 completed the behavior-preserving extraction. `scripts/combat/combat_debug_console.gd` now owns debug command parsing, help text, log storage/rendering, log-level state, command output coloring, and command dispatch. `scripts/combat/combat_turn_logger.gd` now owns normal/detailed turn-log line generation, state snapshot formatting helpers, intent formatting, and reusable outcome/summary strings. `combat_player_controller.gd` still owns combat state, board mutation, RunState/progression mutations, HUD refresh, `/skip` route/state reset, debug fight win/lose outcome routing, resolve presentation callbacks, input, VFX, layout, and scene transitions.
- Plan:
  - Add `scripts/combat/combat_debug_console.gd` for debug command parsing, help text, debug output formatting, command dispatch, and `/skip <level> <fight>` handling.
  - Keep privileged gameplay actions owned by `combat_player_controller.gd`. The debug console should call controller-provided callbacks for actions such as skip routing, run-state mutation, combat refresh, and status updates instead of directly owning gameplay state.
  - Add `scripts/combat/combat_turn_logger.gd` for turn-log text generation, verbosity-specific formatting, summary string construction, and reusable result-envelope display text.
  - Keep combat result dictionaries, `turn_log` shape, debug command names, and visible command output stable unless a confirmed bug is found during extraction.
  - Leave input handling, resolve presentation, combo timing, mastery feedback, VFX spawning, layout management, HUD sync, outcome routing, and RunState transitions in the controller for later AR batches.
- Out of scope:
  - Do not change combat math, enemy intent resolution, rewards, shop routing, boss reward flow, accepted resolve animation order, or scene transitions.
  - Do not start content migration or theme-resource extraction in this batch.
- Validation:
  - `git status --short --branch` confirmed `codex/ar-10-combat-controller-refactor`; `git diff --check` passed.
  - Godot MCP `get_project_info` reported Godot `4.6.2-stable`; `view_script` passed for `combat_player_controller.gd`, `combat_debug_console.gd`, and `combat_turn_logger.gd`; focused `ResourceLoader.CACHE_MODE_IGNORE` probes loaded all three current scripts; `res://scenes/combat/combat_player.tscn` instantiated with `DebugOverlay`, `CombatLogText`, `ConsoleInput`, `BoardSurface`, and `OutcomeSummaryPanel`; `play_scene main` launched with desktop menu WAV playback; final `get_godot_errors` reported no session errors after rerun.
  - Retained AR-01 combat result-envelope probe still matched baseline values: `status=ok`, `combo_count=3`, `heal_amount=4`, `armor_gained=9`, `gold_gained=2`, `enemy_blocked=5`, `enemy_damage_taken=19`, `total_elemental_damage=24`, `enemy_intent_skipped=false`, and `next_phase_name=Intent Preview`.
  - Focused turn-logger probe confirmed the known normal turn summary lines and summary string match the pre-refactor baseline; a broader in-editor console lambda probe returned `<null>` because of MCP tool-script limitations, so representative live debug command click-through remains manual QA.
  - Manual acceptance should cover opening combat, using representative debug commands, completing one normal combat transition, and confirming no visible behavior changed.
- Docs/wiki impact: Update `docs/test_plan.md`, `wiki/architecture.md`, `wiki/file-map.md`, and `wiki/log.md` after the extraction only if the runtime helpers are actually added and validated.

## AR-11: Combat Layout Manager Extraction

- Status: `done`
- Owner/scope: Extracted combat scene geometry and responsive design-space positioning from `scripts/combat/combat_player_controller.gd` into `scripts/combat/combat_layout_manager.gd`.
- Progress: 2026-05-04 completed the behavior-preserving layout extraction. `CombatLayoutManager` now owns viewport/design-root scaling, runtime zone rect calculation, design-rect application, enemy panel positioning, combat strip timer geometry, board panel aspect/shadow geometry, player panel legacy visibility/layout, loadout rail positioning, debug overlay anchoring, `PlayerLoadoutHud` section override dispatch, and outcome overlay board-rect sync. `combat_player_controller.gd` keeps scene node ownership, gameplay state, timer state decisions, input, resolver/presenter orchestration, VFX, HUD data refresh, audio, `/skip`, debug command callbacks, outcome routing, and scene transitions.
- Out of scope:
  - Do not redesign the combat screen, resize gameplay zones beyond existing formulas, or combine this with theme-resource extraction.
  - Do not move `PlayerLoadoutHud` ownership; this AR only moves combat-scene positioning orchestration.
- Validation:
  - `git status --short --branch` confirmed `codex/ar-11-combat-layout-manager`; `git diff --check` passed.
  - Godot MCP `view_script` passed for `res://scripts/combat/combat_player_controller.gd`, `res://scripts/combat/combat_layout_manager.gd`, and `res://scripts/ui/player_loadout_hud.gd`; focused script reload returned `reload=0 base=RefCounted new=true` for the layout helper.
  - Focused `res://scenes/combat/combat_player.tscn` instantiate probe confirmed `CombatLayoutRoot`, `BoardPanel`, `BoardSurface`, `PlayerHudSection`, `DebugOverlay`, and `OutcomeSummaryPanel`.
  - Focused layout probe preserved key formulas: `1080x1920` board `480x576`, `1080x2400` board `880x1056`, tall board panel `1048x1064`, wide viewport root centering/scale, and compact/right-side debug overlay anchoring.
  - Retained AR-01 combat result-envelope probe still matched baseline values: `status=ok`, `combo_count=3`, `heal_amount=4`, `armor_gained=9`, `gold_gained=2`, `enemy_blocked=5`, `enemy_damage_taken=19`, `total_elemental_damage=24`, `enemy_intent_skipped=false`, and `next_phase_name=Intent Preview`.
  - `play_scene main` launched with desktop menu WAV playback and clean recent runtime output. Final `get_godot_errors` still carried two stale enum diagnostics from an earlier failed MCP editor-script probe; focused `view_script` refreshes for `run_state.gd` and `ar01_combat_result_probe.gd` passed, and no project runtime error appeared in the rerun log.
  - Manual visual QA remains required for overlap checks, Android/on-device layout, drag/cascade feel, deferred orb texture-map pop-in, and rapid-tap feel.
- Docs/wiki impact: `docs/test_plan.md`, `wiki/architecture.md`, `wiki/file-map.md`, `wiki/features.md`, and `wiki/log.md` updated for the new layout helper boundary and validation evidence.

## AR-12: Combat VFX Manager Extraction

- Status: `done`
- Owner/scope: Extracted combat VFX spawning and transient replay effect helpers from `scripts/combat/combat_player_controller.gd` into `scripts/combat/combat_vfx_manager.gd`.
- Progress: 2026-05-04 completed the behavior-preserving VFX extraction. `CombatVfxManager` now owns VFX layer binding, texture VFX spawning, replay impact texture lookup/fallback, mastery beam source lookup, global-to-VFX-layer coordinate conversion, beam sizing/rotation/z-index, and fade cleanup through the controller-owned tween owner. `CombatPlayerController` keeps turn-log decisions, replay order, awaits, combat speed timing, mastery preview totals/release semantics, resolver simulation, combat math, input, layout, audio, debug callbacks, `/skip`, outcome routing, and scene transitions.
- Plan:
  - Move texture-based VFX spawning, replay impact spawning, mastery beam spawning, mastery-card source lookup support, global/local coordinate conversion, fade tween lifecycle, and small visual-effect helper decisions that are not combat math.
  - Keep `CombatPlayerController` responsible for deciding when effects happen, which `turn_log` values trigger them, and when awaited replay steps continue or abort.
  - Pass required dependencies explicitly: `VfxLayer`, `VisualRegistry`, `PlayerLoadoutHud`, mastery card root, and timer/tween owner.
  - Preserve mastery feedback timing, pooled feedback release order, beam sizing, impact sizing, target/source placement, and lifecycle guards.
- Out of scope:
  - Do not change combo popup timing, mastery preview math, turn replay order, resolve presentation, VFX art assets, layout, or combat speed behavior.
  - Do not introduce new effects or change visual readability tuning in this refactor batch.
- Validation:
  - `git status --short --branch` confirmed `codex/ar-12-combat-vfx-manager`; `git diff --check` passed.
  - Godot MCP `get_project_info` reported Godot `4.6.2-stable`; `view_script` passed for `res://scripts/combat/combat_player_controller.gd` and `res://scripts/combat/combat_vfx_manager.gd`.
  - Focused helper reload/instantiate probe returned `reload=0 base=RefCounted new=true`.
  - Focused VFX helper probe confirmed a null texture no-op kept `VfxLayer` at `0` children, a spawned texture parented one `TextureRect` under `VfxLayer`, and preserved size plus alpha modulation.
  - Focused `res://scenes/combat/combat_player.tscn` instantiate probe confirmed `VfxLayer`, `ElementalMasteryCards`, `EnemyPortrait`, `PlayerPortrait`, and `BoardSurface`.
  - Retained AR-01 combat result-envelope probe still matched baseline values: `status=ok`, `combo_count=3`, `heal_amount=4`, `armor_gained=9`, `gold_gained=2`, `enemy_blocked=5`, `enemy_damage_taken=19`, `total_elemental_damage=24`, `enemy_intent_skipped=false`, and `next_phase_name=Intent Preview`.
  - `play_scene main` launched with desktop menu WAV playback; final `get_godot_errors` reported no session errors.
  - Manual visual QA remains required for real mastery beams, impact placement, cascade readability, Android/on-device behavior, and overlap checks.
- Docs/wiki impact: `docs/test_plan.md`, `wiki/architecture.md`, `wiki/file-map.md`, `wiki/features.md`, and `wiki/log.md` updated for the new VFX helper boundary and validation evidence.

## AR-13: Board Drag Input Handler Extraction

- Status: `done`
- Owner/scope: Extracted the board drag/pointer input state machine from `scripts/combat/combat_player_controller.gd` into `scripts/combat/board_drag_input_handler.gd`.
- Progress: 2026-05-04 completed the behavior-preserving drag-input extraction. `BoardDragInputHandler` now owns board-local mouse/touch event parsing, active drag state, touch-index tracking, selected orb/current cell/path tracking, adjacent-cell swap bookkeeping, drag timer countdown state, drag visual reset/abort, and live match-glow refresh. `CombatPlayerController` keeps input phase ownership, timer/status rendering, swap SFX policy through a callback, resolve kickoff, visual/simulation board cloning, combat math, resolve presentation, HUD sync, VFX, layout, debug callbacks, `/skip`, outcome routing, and scene transitions.
- Plan:
  - Move pointer/touch drag bookkeeping, selected cell/path tracking, swap-attempt flow, drag visual clearing, and board input event parsing where it can be separated without changing board state rules.
  - Keep `combat_player_controller.gd` responsible for input phase ownership, combat resolve kickoff, audio callback decisions, board-state mutation approval, and post-drag orchestration.
  - Preserve Android touch coordinate behavior through `BoardView.gui_input` local coordinates and avoid reintroducing transform double-application.
  - Keep `/skip`, debug console, layout, resolve presentation, VFX, HUD sync, and route transitions out of this batch.
- Out of scope:
  - Do not change drag movement rules, swap legality, resolver ordering, accepted resolve presentation timing, or combat math.
  - Do not add gesture features, input buffering, rapid-tap behavior changes, or responsive layout fixes.
- Validation:
  - `git status --short --branch` confirmed `codex/ar-13-board-drag-input-handler`; `git diff --check` passed.
  - Godot MCP `view_script` passed for `res://scripts/combat/combat_player_controller.gd` and `res://scripts/combat/board_drag_input_handler.gd`; focused script-load probe returned controller base `Control` and helper base `RefCounted`.
  - Focused helper probes confirmed `BoardView` local coordinate round trip for cell `(2, 4)`, valid drag start, adjacent move swap, invalid start rejection, invalid/non-adjacent move rejection without board mutation, release end action, reset visual state, touch start/second-touch rejection/touch-drag/touch-end behavior, and timeout end action.
  - `res://scenes/combat/combat_player.tscn` instantiated with `CombatLayoutRoot` and `BoardSurface`; retained AR-01 combat result-envelope probe still matched baseline values; `play_scene main` launched with desktop menu WAV playback; final `get_godot_errors` reported no session errors.
  - User manual QA confirmed real mouse drag, Android touch drag, rapid-tap feel, cascade feel after drag release, and board coordinate accuracy passed.
- Docs/wiki impact: `docs/test_plan.md`, `todo.md`, `wiki/architecture.md`, `wiki/file-map.md`, `wiki/features.md`, and `wiki/log.md` updated for the new drag-input helper boundary and validation evidence.

## AR-14: Combat Theme And Chrome Boundary

- Status: `done`
- Owner/scope: Extracted combat style/chrome construction from `scripts/combat/combat_player_controller.gd` into `scripts/combat/combat_chrome_styler.gd`.
- Progress: 2026-05-04 completed the behavior-preserving chrome boundary. `CombatChromeStyler` now owns code-built combat panel/frame styleboxes, progress-bar style construction, label font/color overrides, timer-track and timer-label readability styling, button chrome, board/outcome panel chrome, stat-chip chrome, debug overlay font sizing, shared player-HUD chrome dispatch, and debug zone-guide chrome. `CombatPlayerController` keeps scene node ownership, `_apply_visual_chrome()` orchestration, timer runtime text/fill/color math, placeholder texture creation/assignment, layout, VFX, input, combat math, resolve presentation, route transitions, debug callbacks, `/skip`, and `UiUtils.panel_style(...)` stays untouched.
- Plan:
  - The source inventory found a low-risk helper boundary rather than a `.tres` resource migration.
  - Placeholder texture builders were left in `CombatPlayerController` for AR-15.
  - Existing color, border, radius, margin, font size, timer behavior, and placeholder appearance were preserved.
  - Layout formulas, VFX, input, combat math, resolve presentation, route transitions, and `UiUtils.panel_style(...)` ownership were unchanged.
- Out of scope:
  - Do not migrate shop/final-summary styles or replace `UiUtils.panel_style(...)`.
  - Do not redesign the combat UI, generate new art, or broaden into theme-resource cleanup across the project.
- Validation:
  - `git status --short --branch` confirmed `codex/ar-14-combat-theme-chrome-boundary`; `git diff --check` passed.
  - Godot MCP `get_project_info` reported Godot `4.6.2-stable`; `view_script` passed for `combat_player_controller.gd` and `combat_chrome_styler.gd`.
  - Focused script-load probe returned controller base `Control`, helper reload `0`, and helper base `RefCounted`; `res://scenes/combat/combat_player.tscn` instantiated with `CombatLayoutRoot`, `BoardSurface`, `TimerTrack`, and `OutcomeSummaryPanel`.
  - Focused style probe confirmed representative pre-refactor values: shared frame bg `(0.025, 0.045, 0.07, 0.94)`, border `(0.18, 0.24, 0.31, 0.9)`, border width `1`, radius `4`, margins `8/6`; timer track bg `(0.035, 0.075, 0.11, 0.94)`, border `(0.2, 0.3, 0.4, 0.9)`, border width `1`, radius `4`; timer font `18`, timer-state font `15`, outline `2`, shadow x `1`; enemy HP fill `(0.7, 0.12, 0.13, 1.0)`.
  - Retained AR-01 combat result-envelope probe still matched baseline values; `play_scene main` launched with desktop menu WAV playback; final `get_godot_errors` reported no session errors.
  - User manual QA passed after the helper extraction.
- Docs/wiki impact: `docs/test_plan.md`, `todo.md`, `wiki/architecture.md`, `wiki/file-map.md`, `wiki/features.md`, and `wiki/log.md` updated for the new chrome helper boundary and validation evidence.

## AR-15: Combat Placeholder Texture Utility

- Status: `done`
- Owner/scope: Extracted code-generated combat placeholder texture builders from `scripts/combat/combat_player_controller.gd` into `scripts/combat/combat_placeholder_textures.gd`.
- Progress: 2026-05-04 completed the behavior-preserving placeholder utility extraction. `CombatPlaceholderTextures` now owns only the code-generated timer, intent, enemy portrait, and hero portrait placeholder `ImageTexture` builders. `CombatPlayerController` keeps the fallback decisions, `VisualRegistry` lookup calls, node assignment, visibility toggles, timer runtime behavior, portrait refresh timing, layout, chrome styling, combat math, resolve presentation, routing, debug callbacks, and `/skip`.
- Plan:
  - Moved timer, intent, enemy portrait, and hero portrait placeholder texture creation without changing their pixel shapes, sizes, colors, transparency, or fallback conditions.
  - Keep `CombatPlayerController` responsible for choosing when placeholders are needed and assigning textures to scene nodes.
  - Avoid changing `VisualRegistry` asset lookup, generated art assets, deferred orb texture-map behavior, or combat layout.
- Out of scope:
  - Do not generate new art, migrate placeholders to files, alter portrait mapping, or change visual registry fallback behavior.
  - Do not combine with combat theme/chrome extraction unless AR-14 has already established a helper that should clearly own placeholders.
- Validation:
  - `git status --short --branch` confirmed `codex/ar-15-combat-placeholder-texture-utility`; `git diff --check` passed.
  - Godot MCP `get_project_info` reported Godot `4.6.2-stable`; `view_script` passed for `res://scripts/combat/combat_player_controller.gd` and `res://scripts/combat/combat_placeholder_textures.gd`.
  - Focused texture probe confirmed timer `96x96`, intent `96x96`, enemy `260x230`, and hero `192x192` placeholders plus representative sampled colors/alpha matched the pre-refactor source values.
  - Focused script-load and scene instantiate probe loaded the controller as `Control`, the helper as `RefCounted`, instantiated `res://scenes/combat/combat_player.tscn`, and confirmed `TimerIcon`, `IntentBadge`, `EnemyPortrait`, `PlayerPortrait`, and `BoardSurface` nodes exist.
  - Retained AR-01 combat result-envelope probe still matched baseline values; `play_scene main` launched with desktop menu WAV playback; final `get_godot_errors` reported no session errors.
  - A separate async scene-ready texture-assignment probe hit an MCP tool-script parse limitation before execution, so runtime ready-time placeholder assignment remains covered by existing controller fallback code paths plus main-scene smoke rather than that specific probe.
  - User manual QA passed after the helper extraction.
- Docs/wiki impact: `docs/test_plan.md`, `todo.md`, `wiki/architecture.md`, `wiki/file-map.md`, `wiki/features.md`, and `wiki/log.md` updated for the new helper ownership.

## AR-16: Combat HUD Sync Boundary Review

- Status: `done`
- Owner/scope: Reviewed and reduced remaining HUD data-sync pressure in `scripts/combat/combat_player_controller.gd` after `PlayerLoadoutHud`, AR-10, and the layout/theme/placeholder extractions were stable. `scripts/combat/combat_hud_snapshot_builder.gd` now owns side-effect-free combat HUD snapshot dictionary construction; `CombatPlayerController` still owns scene-node application for top HUD, enemy stage, timer/tempo, player vitals/stat labels, debug overlay, `PlayerLoadoutHud` payload dispatch, placeholder fallback decisions, and loadout rail layout refresh.
- Progress: 2026-05-04 completed the narrow data-boundary extraction. `_update_hud()` now builds one combat HUD snapshot and applies it through the existing `_sync_*` scene update methods. The new helper returns `top_hud`, `enemy_stage`, `tempo_row`, `player_strip`, and `debug_overlay` dictionaries from controller-provided player/enemy/combat/progression/timer data. No `PlayerLoadoutHud` source was changed, so shop HUD behavior, inventory selection/popovers, consumable use signals, sell flow, mastery card rendering, and layout override behavior remain under the existing shared HUD boundary.
- Plan:
  - Inventory `_sync_*` and `_update_hud()` responsibilities and separate pure data snapshot construction from scene-specific label/bar updates where doing so reduces coupling.
  - Prefer pushing reusable player-loadout/mastery data binding into `PlayerLoadoutHud` only when it matches that helper's existing ownership; keep combat-only enemy/timer/status labels in the controller or a combat-specific HUD helper.
  - Preserve shared shop/combat HUD input safety, popover behavior, consumable slot usage, sell-slot callbacks, mastery feedback lanes, and existing player HUD geometry.
  - Keep RunState routing, outcome overlay, resolve presentation, VFX, input handling, layout formulas, and combat math out of this batch.
- Out of scope:
  - Do not redesign HUD layout, move inventory behavior back into combat, or change shop HUD behavior.
  - Do not change Elemental Mastery timing, feedback pooling, or card rendering.
- Validation:
  - `git status --short --branch` confirmed `codex/ar-16-combat-hud-sync-boundary`; `git diff --check` passed.
  - Godot MCP `get_project_info` reported Godot `4.6.2-stable`; `view_script` passed for `res://scripts/combat/combat_player_controller.gd` and `res://scripts/combat/combat_hud_snapshot_builder.gd`.
  - Focused HUD snapshot probe returned helper base `RefCounted`, controller base `Control`, instantiated `res://scenes/combat/combat_player.tscn` and `res://scenes/flow/shop_player.tscn`, and confirmed representative top HUD, enemy, timer, player vitals/stat, truncated turn-summary, and debug snapshot strings.
  - Retained AR-01 combat result-envelope probe still matched baseline values: `status=ok`, `combo_count=3`, `heal_amount=4`, `armor_gained=9`, `gold_gained=2`, `enemy_blocked=5`, `enemy_damage_taken=19`, `total_elemental_damage=24`, `enemy_intent_skipped=false`, and `next_phase_name=Intent Preview`.
  - `play_scene main` launched with desktop menu WAV playback; final `get_godot_errors` reported no session errors.
  - User manual QA passed after the HUD snapshot boundary extraction, covering the AR-16 acceptance surface for combat/shop HUD behavior.
- Docs/wiki impact: `docs/test_plan.md`, `todo.md`, `wiki/architecture.md`, `wiki/file-map.md`, `wiki/features.md`, and `wiki/log.md` updated for the completed HUD snapshot boundary.

## AR-17: Combat Outcome And Transition Boundary Review

- Status: `done`
- Owner/scope: Review the remaining scene transition, outcome routing, and debug fight outcome code in `scripts/combat/combat_player_controller.gd` after lower-risk presentation/debug/input extractions are complete. A narrow behavior-preserving transition glue boundary now lives in `_trace_and_change_scene_to_target(...)`, which centralizes the duplicated combat outcome trace/scene-change call used by the standard Next button, boss reward claim, and boss reward skip paths. `RunState` still owns transition semantics, boss reward state, route constants, final summary routing, and run summaries; `CombatOutcomeOverlay` still owns only outcome/boss-reward presentation.
- Progress: 2026-05-04 source review found a small duplicated route-tracing boundary rather than a new helper file. `_on_next_button_pressed()`, `_claim_boss_reward_option()`, and `_skip_boss_reward_option()` now call `_trace_and_change_scene_to_target(...)` with the same target scenes, route names, trace step names, source strings, and boss-claim `option_index` trace payload as before. Final boss auto-summary routing remains deferred as before. Debug fight win/lose still only prepare pending outcome paths and are intentionally unchanged.
- Plan:
  - Inventory combat-owned outcome paths: normal victory, boss victory reward overlay, final victory summary, defeat summary, debug fight win/lose, next-button routing, route tracing, failed-transition recovery, and `_pending_next_scene_path` ownership.
  - Identify whether any pure formatting or adapter code can move without weakening the current `RunState` transition contract or `CombatOutcomeOverlay` ownership.
  - Preserve AR-09 lifecycle guards, traced combat redirect, final-summary routing, defeat routing to final summary in defeat mode, boss reward routing, audio handoff behavior, and `/skip`.
  - Treat this as a review-first AR; implementation should happen only if the source inventory finds a narrow, behavior-preserving boundary.
- Out of scope:
  - Do not change RunState semantics, boss reward step keys, route names, final summary naming, defeat/victory summary content, scene transitions, audio priority, or overlay layout.
  - Do not merge this with input, VFX, layout, or HUD-sync extraction.
- Validation:
  - `git status --short --branch` confirmed `codex/ar-17-combat-outcome-transition-boundary`; `git diff --check` passed.
  - Godot MCP `get_project_info` reported Godot `4.6.2-stable`; `view_script` passed for `res://scripts/combat/combat_player_controller.gd`.
  - Focused RunState route invariant probe preserved normal fight victory to shop, shop advance to combat, boss victory to combat-hosted boss reward, boss reward skip to shop, final boss victory to `res://scenes/flow/final_run_summary.tscn`, and defeat to `res://scenes/flow/final_run_summary.tscn`.
  - Focused scene instantiate probe passed for `res://scenes/combat/combat_player.tscn`, `res://scenes/flow/shop_player.tscn`, and `res://scenes/flow/final_run_summary.tscn`.
  - Retained AR-01 combat result-envelope probe still matched baseline values; `play_scene main` launched with desktop menu WAV playback; final `get_godot_errors` reported no session errors.
  - User manual QA passed with no issues and no errors after checking normal victory continue, boss reward claim/skip, final boss summary, defeat summary, debug fight win/lose, and main-menu return behavior.
- Docs/wiki impact: `docs/test_plan.md`, `todo.md`, `wiki/architecture.md`, `wiki/file-map.md`, `wiki/features.md`, and `wiki/log.md` updated for the narrowed combat outcome transition glue boundary.

## AR-18: Architecture Review Closeout Before Milestone 10

- Status: `done`
- Owner/scope: Final architecture-review closeout audit before Milestone 10 balance work. Scope is limited to tracker/docs/wiki consistency, remaining AR validation gaps, obsolete temporary diagnostics, deleted validation surfaces, and current source contract checks. No gameplay/runtime behavior changes were made.
- Progress: 2026-05-04 added the final closeout entry after confirming no AR-18 entry existed. The audit found that AR-01 through AR-17 are complete and documented; historical dated notes still mention deleted surfaces such as `board_debug.tscn`, `boss_relic_reward.tscn`, `shop_placeholder.tscn`, and `run_summary_placeholder.tscn`, but AR-08 and later notes already define the current player-facing validation surfaces. Current architecture handoff to Milestone 10 is `main.tscn`, `combat_player.tscn`, `shop_player.tscn`, `final_run_summary.tscn`, retained AR-01 combat result-envelope probes, RunState route probes, and content/scene contract probes.
- Closeout classification:
  - Covered by AR evidence: baseline and post-change route timing capture, combat instantiate stall regression, shared HUD combat/shop behavior, RunState route invariants, dictionary-backed `ContentRegistry` alignment, per-batch `get_godot_errors`, and tracker/wiki synchronization through AR-18.
  - Combat controller refactor status: `scripts/combat/combat_player_controller.gd` is reduced from the pre-AR estimate of about 3357 lines to 2432 lines on the AR-18 branch, a reduction of about 925 lines or 28%. The original high-value leaf extraction target is met: debug console, turn-log formatting, layout/positioning, VFX spawning, drag/pointer input, placeholder textures, resolve presentation, outcome overlay presentation, visual chrome, and side-effect-free HUD snapshot building now live in focused helpers. The controller remains a combat scene coordinator for input phase authority, resolver simulation, combat math handoff, RunState outcome routing, audio hooks, `/skip`, privileged debug callbacks, scene-node HUD application, placeholder fallback assignment, VFX timing decisions, and scene transitions.
  - Still open for Milestone 10 or later QA: board pop-in/perceived transition feel on target hardware, full desktop/mobile overlap sweep, seeded full-run reproducibility, Merchant Compass free-first-reroll behavior, economy/balance tuning, Android audio loop-length listening, and first-playable run/content QA.
  - Future refactor candidates: a `CombatFlowCoordinator` could own post-resolve outcome decisions and route selection; a `CombatHudApplier` could apply `CombatHudSnapshotBuilder` dictionaries to scene labels/bars/nodes; a `CombatTurnOrchestrator` could own the resolve pipeline, but that is higher risk because it touches combat timing, presentation sequencing, and combat math boundaries.
  - Known failure-path follow-ups from closeout review: `final_run_summary.gd` mutates `RunState` for `Start New Run` before confirming the scene transition, so a failed final-summary transition can leave the old summary visible with a fresh active run; `main_boot.gd` switches from menu music to combat music before confirming Start Run transition success, so a failed Start Run transition can leave combat music playing on the main menu. These do not change the accepted normal route evidence, but should be fixed before treating transition failure recovery as fully closed.
  - Retained intentionally for QA: `RunState` FlowTrace logs, combat `ResolveTrace` logs, and the feature-flagged `scripts/debug/ar01_combat_result_probe.gd`; these are documented diagnostics for Milestone 10 QA rather than accidental architecture ownership boundaries.
- Blockers: None for closing the AR tracker. Remaining items are Milestone 10 balance/QA or future scoped cleanup, not AR closeout blockers.
- Validation:
  - `git status --short --branch` confirmed `codex/ar-18-architecture-review-closeout`; `git diff --check` passed before and after documentation edits.
  - Godot MCP `get_project_info` reported Godot `4.6.2-stable`; `view_script` passed for `res://scripts/combat/combat_player_controller.gd`, `res://scripts/core/run_state.gd`, and `res://scripts/debug/ar01_combat_result_probe.gd`.
  - Focused route/content/scene closeout probes confirmed current scenes exist, deleted debug/fallback scenes are absent, `RunState` route constants point to combat/shop/final summary, route invariants preserve normal victory to shop, shop advance to combat, boss reward in combat, boss reward skip to shop, final victory to final summary, and defeat to final summary, and `ContentRegistry.validate_player_state_content()` returns no errors.
  - Retained AR-01 combat result-envelope probe still matched baseline values.
  - `play_scene main` launched with desktop menu WAV playback; final `get_godot_errors` reported no session errors. Post-closeout review added two failure-path transition cleanup follow-ups to `wiki/known-issues.md` and this tracker context; they were not part of the validated normal-route acceptance surface.
- Docs/wiki impact: `docs/architecture_review_tasks.md`, `docs/test_plan.md`, `todo.md`, `wiki/index.md`, `wiki/known-issues.md`, and `wiki/log.md` updated for the closeout and Milestone 10 handoff.

## Post-Review: Scene P1/P2 Cleanup

- Status: `done`
- Owner/scope: Fix the four scene-review findings on `codex/scene-refactor`: Start Run failure-path run/audio mutation, final-summary New Run failure-path run mutation, shop ready-time redirect recovery, and shop-owned Player HUD internal geometry. Scope deliberately excludes scene folder moves and reusable `.tscn` HUD component extraction.
- Progress: 2026-05-06 added `RunState.flow_trace_prepare_scene(...)` and `RunState.flow_trace_attach_prepared_scene(...)` so callers can load/instantiate a target scene, commit run/audio state only after preparation succeeds, and attach through the existing FlowTrace markers. `main_boot.gd` now prepares combat before `RunState.start_new_run()` and combat-music handoff, then restores the prior run snapshot/menu music/button/status if attach fails. `final_run_summary.gd` now prepares combat before clearing the completed summary for New Run, and restores the prior summary/run snapshot plus action buttons on attach failure. `shop_player.gd` replaced no-active-run and wrong-step bare deferred redirects with a deferred traced redirect helper using `RunState.flow_trace_change_scene(...)` and visible failure status. Shop HUD internals moved out of shop-local constants into `PlayerLoadoutHud.shop_player_hud_layout_preset()`, while the shop screen still owns its mount placement and preserves the 30 design-pixel action-to-HUD gap.
- Validation:
  - `git diff --check` passed.
  - Godot MCP `get_project_info` reported Godot `4.6.2-stable`; `view_script` passed for `run_state.gd`, `main_boot.gd`, `final_run_summary.gd`, `shop_player.gd`, `player_loadout_hud.gd`, and `combat_layout_manager.gd`.
  - Focused editor probes passed for transition preparation failure leaving run state unchanged, Start Run attach failure restoring inactive run state, final-summary New Run attach failure preserving the completed summary snapshot, duplicate shop-step snapshot restore, shared shop HUD preset geometry with 30px gap/no action-row overlap, and combat HUD layout probe with no actionable overlap at `1080x1920`.
  - Scene instantiate probe passed for `main.tscn`, `combat_player.tscn`, `shop_player.tscn`, and `final_run_summary.tscn`.
  - Route invariant probe passed for new run to combat, fight victory to shop, shop advance to combat, final victory to final summary, and defeat to final summary.
  - Initial `get_godot_errors` after script loads showed only the existing stale enum reload warnings and no new touched-script parse errors. Final `play_scene main` launched the menu with desktop `MainMenuMusicPlayer` playback and `get_godot_errors` reported no session errors.
- Docs/wiki impact: `docs/architecture_review_tasks.md`, `docs/test_plan.md`, `wiki/known-issues.md`, `wiki/architecture.md`, `wiki/file-map.md`, `wiki/features.md`, and `wiki/log.md` updated for the resolved transition/HUD findings.
