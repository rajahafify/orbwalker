# Architecture Review Task Tracker

Purpose: track architecture-review follow-up work with explicit status, progress, blockers, validation gates, and documentation impact. This is the entry point for architecture-maintenance tasks before Milestone 10 balance closure.

Status values: `not started`, `in progress`, `blocked`, `done`, `deferred`.

## AR-01: Baseline Regression Harness

- Status: `done`
- Owner/scope: Regression checklist and Godot MCP probe workflow for board resolver, combat state machine, shop service, RunState routing, audio loading, and shared HUD selection.
- Progress: 2026-05-03 baseline evidence captured in `docs/test_plan.md` for branch/worktree state, `git diff --check`, `get_project_info`, `get_godot_errors`, main/combat/board-debug/shop scene smokes, user runtime route timings for `Start Run -> Combat`, `Combat -> Shop`, and `Shop -> Combat`, board resolver known cases, combat state machine result envelope, shop service buy/reroll/sell/booster basics, RunState route invariants, audio stream loading, and minimal `PlayerLoadoutHud` selection/popover behavior.
- Blockers: None for AR-01 baseline capture. Remaining manual QA items such as texture-map visual pop-in, live HUD sell flow, overlap checks, and integer-division warning cleanup stay tracked outside AR-01 completion.
- Next action: Use the retained AR-01 harness as the pre-refactor comparison point for AR-02 and later architecture-touching batches.
- Validation: Static checks pass; Godot MCP checks cover `res://scenes/main_menu.tscn`, `res://scenes/combat.tscn`, `res://scenes/combat/board_debug.tscn`, and `res://scenes/shop.tscn`; focused probes record expected result envelopes for deterministic systems.
- Docs/wiki impact: `docs/test_plan.md`, `wiki/file-map.md`, `wiki/setup.md`, `wiki/known-issues.md`, and `wiki/log.md` updated for the retained feature-flagged AR-01 probe and captured baseline.

## AR-02: Low-Risk Bug Fixes

- Status: `done`
- Owner/scope: Small confirmed issues such as `EnemyState.get_current_intent()` mutation, main-menu music polling after success, noisy audio diagnostics, and await/transition guards.
- Progress: 2026-05-03 completed the low-risk batch. `EnemyState.get_current_intent()` returns a duplicated intent snapshot before adding the derived `index`, keeping the caller contract unchanged while making the read API non-mutating by construction. The main-menu music retry poll stops after successful desktop playback or Android/template `AudioManager` routing while preserving retry behavior for failed setup. Verbose `AudioManager` music diagnostics are gated behind `debug/audio_diagnostics_enabled=false` by default. Run-flow entry/exit controls now have local duplicate-transition guards for Start Run, player-shop Continue/Menu, legacy boss-reward Skip/Continue, and legacy shop Skip/Next/Menu; player-shop and legacy reward/shop advance actions now check failed `RunState` transition results before routing.
- Blockers: None for AR-02 completion. Known unsourced Godot integer-division reload warnings remain tracked outside this low-risk batch.
- Next action: Move to AR-03 shared WAV/audio utility extraction or AR-04 shop/input safety after choosing the next architecture-review batch.
- Validation: Intent snapshot probe passed; main scene smoke confirmed desktop `MainMenuMusicPlayer` playback; focused audio setting probe confirmed diagnostics are opt-in; transition scene instantiate probes passed for `res://scenes/main_menu.tscn`, `res://scenes/shop.tscn`, `res://scenes/flow/boss_relic_reward.tscn`, and `res://scenes/flow/shop_placeholder.tscn`; retained AR-01 combat result-envelope probe still matched the documented baseline. Fresh `get_godot_errors` returned no session errors after script/instantiate checks; after main scene smoke it still reported the known unsourced integer-division reload warnings.
- Docs/wiki impact: `docs/test_plan.md`, `wiki/features.md`, and `wiki/log.md` updated for the completed AR-02 batch.

## AR-03: Shared WAV/Audio Utility Extraction

- Status: `done`
- Owner/scope: Shared WAV parsing, frame-count, and loop configuration logic currently duplicated between `scripts/core/audio_manager.gd` and `scripts/scenes/main_menu.gd`.
- Progress: 2026-05-03 completed the extraction by adding `scripts/core/audio_stream_loader.gd` as the shared helper for file byte loading, signed PCM16 WAV parsing, imported `AudioStream` loop configuration, WAV loop bounds, and source-header frame counts. `scripts/core/audio_manager.gd` and `scripts/scenes/main_menu.gd` now call the shared loader instead of carrying duplicate WAV helper implementations. Generated music/SFX remains owned by `AudioManager`, and the AR-02 desktop shop-to-main-menu audio handoff remains unchanged: desktop main menu stops shared `AudioManager` music before local `MainMenuMusicPlayer` playback, while Android/template menu music still routes through `AudioManager`.
- Blockers: None for AR-03 completion. Android/on-device listening and loop-length acceptance remains manual unless explicitly retested on hardware.
- Next action: Move to AR-04 shop/input safety or another architecture-review batch.
- Validation: Pre-change and post-change Godot MCP audio probes matched for menu/combat/shop WAV stream class, volume, data bytes, and loop ends; generated `swap` SFX still builds; the direct main-menu music loader returns the same WAV data and loop end; the focused shared-music stop probe still reports `before_key=shop before_playing=true after_key= after_playing=false`; retained AR-01 combat result-envelope probe still matched baseline; `play_scene main` launched with desktop `MainMenuMusicPlayer` playback and `get_godot_errors` reported no session errors.
- Docs/wiki impact: `docs/test_plan.md`, `wiki/features.md`, `wiki/file-map.md`, and `wiki/log.md` updated for the new shared audio loader ownership.

## AR-04: Shop/Input Safety

- Status: `done`
- Owner/scope: `scripts/scenes/shop.gd`, `scripts/shop/shop_service.gd`, and shared `scripts/ui/player_loadout_hud.gd` interaction behavior.
- Progress: 2026-05-03 completed the shop/input safety batch. `PlayerLoadoutHud` hover now previews item details without mutating committed equipment or consumable selection; Sell is shown only when the hovered equipment/consumable slot matches the clicked selected slot. `shop_player.gd` now routes touch outside-dismissal through the same shared HUD focus handler as mouse clicks and adds a same-frame action guard around buy, relic buy, reroll, sell, booster pick, and booster skip handlers so one input frame cannot execute duplicate shop transactions. Manual QA then found the first outside-dismiss route still failed on PC and Android because handled UI events did not reach `_unhandled_input`; the shop now performs the dismissal check in `_input` without marking the event handled. A second manual follow-up found the popover closed but selected chrome stayed active; outside-dismiss now clears inventory focus and refreshes the shop UI so slot selection re-renders cleared.
- Blockers: None for the AR-04 code batch. Live visual overlap checks, texture-map pop-in, and Android listening remain manual QA unless explicitly retested.
- Next action: Move to the next selected architecture-review batch after any desired manual shop/touch QA.
- Validation: Godot MCP `view_script` checks passed for `res://scripts/ui/player_loadout_hud.gd` and `res://scripts/scenes/shop.gd`; focused editor-script probes confirmed hover preserves committed selection through hover enter/exit, click selection still commits, Sell appears only for the selected hovered slot, outside-click focus dismissal clears selection, same-frame shop action calls are guarded, and `res://scenes/shop.tscn` instantiates. Follow-up source-shape and scene instantiate probes passed after moving outside-dismissal to `_input`; `view_script` and `get_godot_errors` passed after the focus-clear/refresh follow-up. Final `get_godot_errors` reported no session errors. User manual QA confirmed the outside-dismissal and visual deselection fixes on PC and Android.
- Docs/wiki impact: `docs/test_plan.md`, `todo.md`, `wiki/features.md`, `wiki/known-issues.md`, and `wiki/log.md` updated for the completed AR-04 batch.

## AR-05: Combat Controller First Split

- Status: `done`
- Owner/scope: First behavior-preserving extraction from `scripts/scenes/combat.gd`; `scripts/combat/combat_outcome_overlay.gd` now owns the combat outcome overlay presentation boundary for standard victory/defeat cards, boss reward card controls, scrim layering, and overlay layout.
- Progress: 2026-05-03 completed the first split. `combat_player_controller.gd` still owns combat math, resolve presentation timing, RunState victory/defeat/boss-reward routing, audio calls, scene transitions, input phase changes, debug console commands, and `/skip`; `CombatOutcomeOverlay` owns only outcome/boss-reward UI state, card content/layout, visibility, and helper text wrapping.
- Blockers: None for AR-05 completion. Broader combat presentation extraction was handled by later AR slices; final public visual regression checks are transferred to `docs/itch_readiness_tasks.md`.
- Next action: Move to AR-06 only after choosing a presentation-only boundary that preserves the accepted resolve order.
- Validation: Godot MCP `view_script` checks passed for `res://scripts/combat/combat_outcome_overlay.gd` and `res://scripts/scenes/combat.gd`; focused editor-script probes confirmed helper load/methods, `res://scenes/combat.tscn` instantiate, outcome node presence, helper boss-reward controls/scrim/layout state, standard summary state, boss reward state, hide state, and text wrapping. Retained AR-01 combat result-envelope probe still matched baseline values. Final `get_godot_errors` reported no session errors. User manual QA confirmed normal victory continue, boss reward claim/skip, defeat Main Menu, final-boss summary, debug console commands, and resolve presentation order remained good.
- Docs/wiki impact: `docs/test_plan.md`, `todo.md`, `wiki/architecture.md`, `wiki/file-map.md`, and `wiki/log.md` updated for the new helper ownership.

## AR-06: Combat Presentation Split

- Status: `done`
- Owner/scope: `scripts/combat/combat_resolve_presenter.gd` now owns the board-space resolve replay presentation boundary: match-group presentation sorting, match flash waits, clear/gravity/refill animation timing, visual board commits, clear burst spawning, combo popup lifecycle, and `combat_speed` duration/wait behavior. `scripts/scenes/combat.gd` still owns drag/input lifecycle, resolver simulation, combat math, mastery preview value calculation and HUD feedback decisions, RunState routing, outcome overlay routing, audio routing callbacks, scene transitions, debug console, and `/skip`.
- Progress: 2026-05-03 completed the presentation split with a callback boundary from the controller into `CombatResolvePresenter`. The accepted visible ordering is preserved by keeping the replay sequence as match flash, clear animation, visual clear commit, `combo_tick` trace, combo popup/mastery preview, gravity animation/commit, refill animation/commit. AR-08 cleanup candidates were left untouched.
- Blockers: None for the AR-06 code batch. Manual visual QA on Android passed for the AR-06 combat presentation checks; broader desktop/mobile overlap and deferred orb texture-map pop-in review remain useful outside this batch.
- Next action: Move to AR-07 or another selected architecture-review batch.
- Validation: Godot MCP `view_script` checks passed for `res://scripts/combat/combat_resolve_presenter.gd` and `res://scripts/scenes/combat.gd`; `res://scenes/combat.tscn` instantiated with board and outcome nodes; retained AR-01 combat result-envelope probe still matched baseline values; `play_scene main` launched successfully with no runtime errors; final `get_godot_errors` reported no session errors. A first attempt at a focused async presenter-order editor probe hit an MCP tool-script parse limitation before execution. User manual QA on the installed Android build confirmed AR-06 presentation behavior works.
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
- Validation: Godot MCP `view_script` passed for touched scripts; `get_godot_errors` reported no session errors; retained AR-01 combat result-envelope probe still matched baseline; RunState route probes preserved combat/shop/boss-reward/final-victory route shapes with final victory routing to `res://scenes/run_summary.tscn`; defeat now also routes to `res://scenes/run_summary.tscn` in defeat mode while reset/no-summary inactive state still routes to main; main, combat, shop, and final summary scenes instantiate/run as validation surfaces; deleted-scene reference searches are clean; `git diff --check` passed.
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
- Owner/scope: Reduce `scripts/scenes/combat.gd` by extracting the lowest-risk remaining responsibilities after AR-09 stability cleanup. First extraction target is debug console ownership plus turn-log formatting, because those areas are large, mostly isolated, and less coupled to combat math or resolve timing than input, layout, VFX, HUD sync, or routing.
- Progress: 2026-05-04 completed the behavior-preserving extraction. `scripts/combat/combat_debug_console.gd` now owns debug command parsing, help text, log storage/rendering, log-level state, command output coloring, and command dispatch. `scripts/combat/combat_turn_log_presenter.gd` now owns normal/detailed turn-log line generation, state snapshot formatting helpers, intent formatting, and reusable outcome/summary strings. `combat_player_controller.gd` still owns combat state, board mutation, RunState/progression mutations, HUD refresh, `/skip` route/state reset, debug fight win/lose outcome routing, resolve presentation callbacks, input, VFX, layout, and scene transitions.
- Plan:
  - Add `scripts/combat/combat_debug_console.gd` for debug command parsing, help text, debug output formatting, command dispatch, and `/skip <level> <fight>` handling.
  - Keep privileged gameplay actions owned by `combat_player_controller.gd`. The debug console should call controller-provided callbacks for actions such as skip routing, run-state mutation, combat refresh, and status updates instead of directly owning gameplay state.
  - Add `scripts/combat/combat_turn_log_presenter.gd` for turn-log text generation, verbosity-specific formatting, summary string construction, and reusable result-envelope display text.
  - Keep combat result dictionaries, `turn_log` shape, debug command names, and visible command output stable unless a confirmed bug is found during extraction.
  - Leave input handling, resolve presentation, combo timing, mastery feedback, VFX spawning, layout management, HUD sync, outcome routing, and RunState transitions in the controller for later AR batches.
- Out of scope:
  - Do not change combat math, enemy intent resolution, rewards, shop routing, boss reward flow, accepted resolve animation order, or scene transitions.
  - Do not start content migration or theme-resource extraction in this batch.
- Validation:
  - `git status --short --branch` confirmed `codex/ar-10-combat-controller-refactor`; `git diff --check` passed.
  - Godot MCP `get_project_info` reported Godot `4.6.2-stable`; `view_script` passed for `combat_player_controller.gd`, `combat_debug_console.gd`, and `combat_turn_log_presenter.gd`; focused `ResourceLoader.CACHE_MODE_IGNORE` probes loaded all three current scripts; `res://scenes/combat.tscn` instantiated with `DebugOverlay`, `CombatLogText`, `ConsoleInput`, `Board`, and `OutcomeSummaryPanel`; `play_scene main` launched with desktop menu WAV playback; final `get_godot_errors` reported no session errors after rerun.
  - Retained AR-01 combat result-envelope probe still matched baseline values: `status=ok`, `combo_count=3`, `heal_amount=4`, `armor_gained=9`, `gold_gained=2`, `enemy_blocked=5`, `enemy_damage_taken=19`, `total_elemental_damage=24`, `enemy_intent_skipped=false`, and `next_phase_name=Intent Preview`.
  - Focused turn-logger probe confirmed the known normal turn summary lines and summary string match the pre-refactor baseline; a broader in-editor console lambda probe returned `<null>` because of MCP tool-script limitations, so representative live debug command click-through remains manual QA.
  - Manual acceptance should cover opening combat, using representative debug commands, completing one normal combat transition, and confirming no visible behavior changed.
- Docs/wiki impact: Update `docs/test_plan.md`, `wiki/architecture.md`, `wiki/file-map.md`, and `wiki/log.md` after the extraction only if the runtime helpers are actually added and validated.

## AR-11: Combat layout presenter extraction

- Status: `done`
- Owner/scope: Extracted combat scene geometry and responsive design-space positioning from `scripts/scenes/combat.gd` into `scripts/combat/combat_layout_presenter.gd`.
- Progress: 2026-05-04 completed the behavior-preserving layout extraction. `CombatLayoutPresenter` now owns viewport/design-root scaling, runtime zone rect calculation, design-rect application, enemy panel positioning, combat strip timer geometry, board panel aspect/shadow geometry, player panel legacy visibility/layout, loadout rail positioning, debug overlay anchoring, `PlayerLoadoutHud` section override dispatch, and outcome overlay board-rect sync. `combat_player_controller.gd` keeps scene node ownership, gameplay state, timer state decisions, input, resolver/presenter orchestration, VFX, HUD data refresh, audio, `/skip`, debug command callbacks, outcome routing, and scene transitions.
- Out of scope:
  - Do not redesign the combat screen, resize gameplay zones beyond existing formulas, or combine this with theme-resource extraction.
  - Do not move `PlayerLoadoutHud` ownership; this AR only moves combat-scene positioning orchestration.
- Validation:
  - `git status --short --branch` confirmed `codex/ar-11-combat-layout-manager`; `git diff --check` passed.
  - Godot MCP `view_script` passed for `res://scripts/scenes/combat.gd`, `res://scripts/combat/combat_layout_presenter.gd`, and `res://scripts/ui/player_loadout_hud.gd`; focused script reload returned `reload=0 base=RefCounted new=true` for the layout helper.
  - Focused `res://scenes/combat.tscn` instantiate probe confirmed `CombatLayoutRoot`, `BoardPanel`, `Board`, `PlayerHudSection`, `DebugOverlay`, and `OutcomeSummaryPanel`.
  - Focused layout probe preserved key formulas: `1080x1920` board `480x576`, `1080x2400` board `880x1056`, tall board panel `1048x1064`, wide viewport root centering/scale, and compact/right-side debug overlay anchoring.
  - Retained AR-01 combat result-envelope probe still matched baseline values: `status=ok`, `combo_count=3`, `heal_amount=4`, `armor_gained=9`, `gold_gained=2`, `enemy_blocked=5`, `enemy_damage_taken=19`, `total_elemental_damage=24`, `enemy_intent_skipped=false`, and `next_phase_name=Intent Preview`.
  - `play_scene main` launched with desktop menu WAV playback and clean recent runtime output. Final `get_godot_errors` still carried two stale enum diagnostics from an earlier failed MCP editor-script probe; focused `view_script` refreshes for `run_state.gd` and `ar01_combat_result_probe.gd` passed, and no project runtime error appeared in the rerun log.
  - Manual visual QA remains required for overlap checks, Android/on-device layout, drag/cascade feel, deferred orb texture-map pop-in, and rapid-tap feel.
- Docs/wiki impact: `docs/test_plan.md`, `wiki/architecture.md`, `wiki/file-map.md`, `wiki/features.md`, and `wiki/log.md` updated for the new layout helper boundary and validation evidence.

## AR-12: Combat VFX presenter extraction

- Status: `done`
- Owner/scope: Extracted combat VFX spawning and transient replay effect helpers from `scripts/scenes/combat.gd` into `scripts/combat/combat_vfx_presenter.gd`.
- Progress: 2026-05-04 completed the behavior-preserving VFX extraction. `CombatVfxPresenter` now owns VFX layer binding, texture VFX spawning, replay impact texture lookup/fallback, mastery beam source lookup, global-to-VFX-layer coordinate conversion, beam sizing/rotation/z-index, and fade cleanup through the controller-owned tween owner. `CombatPlayerController` keeps turn-log decisions, replay order, awaits, combat speed timing, mastery preview totals/release semantics, resolver simulation, combat math, input, layout, audio, debug callbacks, `/skip`, outcome routing, and scene transitions.
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
  - Godot MCP `get_project_info` reported Godot `4.6.2-stable`; `view_script` passed for `res://scripts/scenes/combat.gd` and `res://scripts/combat/combat_vfx_presenter.gd`.
  - Focused helper reload/instantiate probe returned `reload=0 base=RefCounted new=true`.
  - Focused VFX helper probe confirmed a null texture no-op kept `VfxLayer` at `0` children, a spawned texture parented one `TextureRect` under `VfxLayer`, and preserved size plus alpha modulation.
  - Focused `res://scenes/combat.tscn` instantiate probe confirmed `VfxLayer`, `ElementalMasteryCards`, `EnemyPortrait`, `PlayerPortrait`, and `Board`.
  - Retained AR-01 combat result-envelope probe still matched baseline values: `status=ok`, `combo_count=3`, `heal_amount=4`, `armor_gained=9`, `gold_gained=2`, `enemy_blocked=5`, `enemy_damage_taken=19`, `total_elemental_damage=24`, `enemy_intent_skipped=false`, and `next_phase_name=Intent Preview`.
  - `play_scene main` launched with desktop menu WAV playback; final `get_godot_errors` reported no session errors.
  - Manual visual QA remains required for real mastery beams, impact placement, cascade readability, Android/on-device behavior, and overlap checks.
- Docs/wiki impact: `docs/test_plan.md`, `wiki/architecture.md`, `wiki/file-map.md`, `wiki/features.md`, and `wiki/log.md` updated for the new VFX helper boundary and validation evidence.

## AR-13: Board Drag Input Handler Extraction

- Status: `done`
- Owner/scope: Extracted the board drag/pointer input state machine from `scripts/scenes/combat.gd` into `scripts/board/board_controller.gd`.
- Progress: 2026-05-04 completed the behavior-preserving drag-input extraction. `BoardController` now owns board-local mouse/touch event parsing, active drag state, touch-index tracking, selected orb/current cell/path tracking, adjacent-cell swap bookkeeping, drag timer countdown state, drag visual reset/abort, and live match-glow refresh. `CombatPlayerController` keeps input phase ownership, timer/status rendering, swap SFX policy through a callback, resolve kickoff, visual/simulation board cloning, combat math, resolve presentation, HUD sync, VFX, layout, debug callbacks, `/skip`, outcome routing, and scene transitions.
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
  - Godot MCP `view_script` passed for `res://scripts/scenes/combat.gd` and `res://scripts/board/board_controller.gd`; focused script-load probe returned controller base `Control` and helper base `RefCounted`.
  - Focused helper probes confirmed `BoardView` local coordinate round trip for cell `(2, 4)`, valid drag start, adjacent move swap, invalid start rejection, invalid/non-adjacent move rejection without board mutation, release end action, reset visual state, touch start/second-touch rejection/touch-drag/touch-end behavior, and timeout end action.
  - `res://scenes/combat.tscn` instantiated with `CombatLayoutRoot` and `Board`; retained AR-01 combat result-envelope probe still matched baseline values; `play_scene main` launched with desktop menu WAV playback; final `get_godot_errors` reported no session errors.
  - User manual QA confirmed real mouse drag, Android touch drag, rapid-tap feel, cascade feel after drag release, and board coordinate accuracy passed.
- Docs/wiki impact: `docs/test_plan.md`, `todo.md`, `wiki/architecture.md`, `wiki/file-map.md`, `wiki/features.md`, and `wiki/log.md` updated for the new drag-input helper boundary and validation evidence.

## AR-14: Combat Theme And Chrome Boundary

- Status: `done`
- Owner/scope: Extracted combat style/chrome construction from `scripts/scenes/combat.gd` into `scripts/combat/combat_chrome_styler.gd`.
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
  - Focused script-load probe returned controller base `Control`, helper reload `0`, and helper base `RefCounted`; `res://scenes/combat.tscn` instantiated with `CombatLayoutRoot`, `Board`, `TimerTrack`, and `OutcomeSummaryPanel`.
  - Focused style probe confirmed representative pre-refactor values: shared frame bg `(0.025, 0.045, 0.07, 0.94)`, border `(0.18, 0.24, 0.31, 0.9)`, border width `1`, radius `4`, margins `8/6`; timer track bg `(0.035, 0.075, 0.11, 0.94)`, border `(0.2, 0.3, 0.4, 0.9)`, border width `1`, radius `4`; timer font `18`, timer-state font `15`, outline `2`, shadow x `1`; enemy HP fill `(0.7, 0.12, 0.13, 1.0)`.
  - Retained AR-01 combat result-envelope probe still matched baseline values; `play_scene main` launched with desktop menu WAV playback; final `get_godot_errors` reported no session errors.
  - User manual QA passed after the helper extraction.
- Docs/wiki impact: `docs/test_plan.md`, `todo.md`, `wiki/architecture.md`, `wiki/file-map.md`, `wiki/features.md`, and `wiki/log.md` updated for the new chrome helper boundary and validation evidence.

## AR-15: Combat Placeholder Texture Utility

- Status: `done`
- Owner/scope: Extracted code-generated combat placeholder texture builders from `scripts/scenes/combat.gd` into `scripts/combat/combat_placeholder_textures.gd`.
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
  - Godot MCP `get_project_info` reported Godot `4.6.2-stable`; `view_script` passed for `res://scripts/scenes/combat.gd` and `res://scripts/combat/combat_placeholder_textures.gd`.
  - Focused texture probe confirmed timer `96x96`, intent `96x96`, enemy `260x230`, and hero `192x192` placeholders plus representative sampled colors/alpha matched the pre-refactor source values.
  - Focused script-load and scene instantiate probe loaded the controller as `Control`, the helper as `RefCounted`, instantiated `res://scenes/combat.tscn`, and confirmed `TimerIcon`, `IntentBadge`, `EnemyPortrait`, `PlayerPortrait`, and `Board` nodes exist.
  - Retained AR-01 combat result-envelope probe still matched baseline values; `play_scene main` launched with desktop menu WAV playback; final `get_godot_errors` reported no session errors.
  - A separate async scene-ready texture-assignment probe hit an MCP tool-script parse limitation before execution, so runtime ready-time placeholder assignment remains covered by existing controller fallback code paths plus main-scene smoke rather than that specific probe.
  - User manual QA passed after the helper extraction.
- Docs/wiki impact: `docs/test_plan.md`, `todo.md`, `wiki/architecture.md`, `wiki/file-map.md`, `wiki/features.md`, and `wiki/log.md` updated for the new helper ownership.

## AR-16: Combat HUD Sync Boundary Review

- Status: `done`
- Owner/scope: Reviewed and reduced remaining HUD data-sync pressure in `scripts/scenes/combat.gd` after `PlayerLoadoutHud`, AR-10, and the layout/theme/placeholder extractions were stable. `scripts/combat/combat_hud_presenter.gd` now owns side-effect-free combat HUD snapshot dictionary construction; `CombatPlayerController` still owns scene-node application for top HUD, enemy stage, timer/tempo, player vitals/stat labels, debug overlay, `PlayerLoadoutHud` payload dispatch, placeholder fallback decisions, and loadout rail layout refresh.
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
  - Godot MCP `get_project_info` reported Godot `4.6.2-stable`; `view_script` passed for `res://scripts/scenes/combat.gd` and `res://scripts/combat/combat_hud_presenter.gd`.
  - Focused HUD snapshot probe returned helper base `RefCounted`, controller base `Control`, instantiated `res://scenes/combat.tscn` and `res://scenes/shop.tscn`, and confirmed representative top HUD, enemy, timer, player vitals/stat, truncated turn-summary, and debug snapshot strings.
  - Retained AR-01 combat result-envelope probe still matched baseline values: `status=ok`, `combo_count=3`, `heal_amount=4`, `armor_gained=9`, `gold_gained=2`, `enemy_blocked=5`, `enemy_damage_taken=19`, `total_elemental_damage=24`, `enemy_intent_skipped=false`, and `next_phase_name=Intent Preview`.
  - `play_scene main` launched with desktop menu WAV playback; final `get_godot_errors` reported no session errors.
  - User manual QA passed after the HUD snapshot boundary extraction, covering the AR-16 acceptance surface for combat/shop HUD behavior.
- Docs/wiki impact: `docs/test_plan.md`, `todo.md`, `wiki/architecture.md`, `wiki/file-map.md`, `wiki/features.md`, and `wiki/log.md` updated for the completed HUD snapshot boundary.

## AR-17: Combat Outcome And Transition Boundary Review

- Status: `done`
- Owner/scope: Review the remaining scene transition, outcome routing, and debug fight outcome code in `scripts/scenes/combat.gd` after lower-risk presentation/debug/input extractions are complete. A narrow behavior-preserving transition glue boundary now lives in `_trace_and_change_scene_to_target(...)`, which centralizes the duplicated combat outcome trace/scene-change call used by the standard Next button, boss reward claim, and boss reward skip paths. `RunState` still owns transition semantics, boss reward state, route constants, final summary routing, and run summaries; `CombatOutcomeOverlay` still owns only outcome/boss-reward presentation.
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
  - Godot MCP `get_project_info` reported Godot `4.6.2-stable`; `view_script` passed for `res://scripts/scenes/combat.gd`.
  - Focused RunState route invariant probe preserved normal fight victory to shop, shop advance to combat, boss victory to combat-hosted boss reward, boss reward skip to shop, final boss victory to `res://scenes/run_summary.tscn`, and defeat to `res://scenes/run_summary.tscn`.
  - Focused scene instantiate probe passed for `res://scenes/combat.tscn`, `res://scenes/shop.tscn`, and `res://scenes/run_summary.tscn`.
  - Retained AR-01 combat result-envelope probe still matched baseline values; `play_scene main` launched with desktop menu WAV playback; final `get_godot_errors` reported no session errors.
  - User manual QA passed with no issues and no errors after checking normal victory continue, boss reward claim/skip, final boss summary, defeat summary, debug fight win/lose, and main-menu return behavior.
- Docs/wiki impact: `docs/test_plan.md`, `todo.md`, `wiki/architecture.md`, `wiki/file-map.md`, `wiki/features.md`, and `wiki/log.md` updated for the narrowed combat outcome transition glue boundary.

## AR-18: Architecture Review Closeout Before Milestone 10

- Status: `done`
- Owner/scope: Final architecture-review closeout audit before Milestone 10 balance work. Scope is limited to tracker/docs/wiki consistency, remaining AR validation gaps, obsolete temporary diagnostics, deleted validation surfaces, and current source contract checks. No gameplay/runtime behavior changes were made.
- Progress: 2026-05-04 added the final closeout entry after confirming no AR-18 entry existed. The audit found that AR-01 through AR-17 are complete and documented; historical dated notes still mention deleted surfaces such as `board_debug.tscn`, `boss_relic_reward.tscn`, `shop_placeholder.tscn`, and `run_summary_placeholder.tscn`, but AR-08 and later notes already define the current player-facing validation surfaces. Current architecture handoff to Milestone 10 is `main.tscn`, `combat_player.tscn`, `shop_player.tscn`, `final_run_summary.tscn`, retained AR-01 combat result-envelope probes, RunState route probes, and content/scene contract probes.
- Closeout classification:
  - Covered by AR evidence: baseline and post-change route timing capture, combat instantiate stall regression, shared HUD combat/shop behavior, RunState route invariants, dictionary-backed `ContentRegistry` alignment, per-batch `get_godot_errors`, and tracker/wiki synchronization through AR-18.
  - Combat controller refactor status: `scripts/scenes/combat.gd` is reduced from the pre-AR estimate of about 3357 lines to 2432 lines on the AR-18 branch, a reduction of about 925 lines or 28%. The original high-value leaf extraction target is met: debug console, turn-log formatting, layout/positioning, VFX spawning, drag/pointer input, placeholder textures, resolve presentation, outcome overlay presentation, visual chrome, and side-effect-free HUD snapshot building now live in focused helpers. The controller remains a combat scene coordinator for input phase authority, resolver simulation, combat math handoff, RunState outcome routing, audio hooks, `/skip`, privileged debug callbacks, scene-node HUD application, placeholder fallback assignment, VFX timing decisions, and scene transitions.
  - Still open for Milestone 10 or later QA: board pop-in/perceived transition feel on target hardware, full desktop/mobile overlap sweep, seeded full-run reproducibility, Merchant Compass free-first-reroll behavior, economy/balance tuning, Android audio loop-length listening, and first-playable run/content QA.
  - Future refactor candidates: a `CombatFlowCoordinator` could own post-resolve outcome decisions and route selection; a `CombatHudApplier` could apply `CombatHudPresenter` dictionaries to scene labels/bars/nodes; a `CombatTurnOrchestrator` could own the resolve pipeline, but that is higher risk because it touches combat timing, presentation sequencing, and combat math boundaries.
  - Known failure-path follow-ups from closeout review: `final_run_summary.gd` mutates `RunState` for `Start New Run` before confirming the scene transition, so a failed final-summary transition can leave the old summary visible with a fresh active run; `main_boot.gd` switches from menu music to combat music before confirming Start Run transition success, so a failed Start Run transition can leave combat music playing on the main menu. These do not change the accepted normal route evidence, but should be fixed before treating transition failure recovery as fully closed.
  - Retained intentionally for QA: `RunState` FlowTrace logs, combat `ResolveTrace` logs, and the feature-flagged `scripts/debug/ar01_combat_result_probe.gd`; these are documented diagnostics for Milestone 10 QA rather than accidental architecture ownership boundaries.
- Blockers: None for closing the AR tracker. Remaining items are Milestone 10 balance/QA or future scoped cleanup, not AR closeout blockers.
- Validation:
  - `git status --short --branch` confirmed `codex/ar-18-architecture-review-closeout`; `git diff --check` passed before and after documentation edits.
  - Godot MCP `get_project_info` reported Godot `4.6.2-stable`; `view_script` passed for `res://scripts/scenes/combat.gd`, `res://scripts/core/run_state.gd`, and `res://scripts/debug/ar01_combat_result_probe.gd`.
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
  - Godot MCP `get_project_info` reported Godot `4.6.2-stable`; `view_script` passed for `run_state.gd`, `main_boot.gd`, `final_run_summary.gd`, `shop_player.gd`, `player_loadout_hud.gd`, and `combat_layout_presenter.gd`.
  - Focused editor probes passed for transition preparation failure leaving run state unchanged, Start Run attach failure restoring inactive run state, final-summary New Run attach failure preserving the completed summary snapshot, duplicate shop-step snapshot restore, shared shop HUD preset geometry with 30px gap/no action-row overlap, and combat HUD layout probe with no actionable overlap at `1080x1920`.
  - Scene instantiate probe passed for `main.tscn`, `combat_player.tscn`, `shop_player.tscn`, and `final_run_summary.tscn`.
  - Route invariant probe passed for new run to combat, fight victory to shop, shop advance to combat, final victory to final summary, and defeat to final summary.
  - Initial `get_godot_errors` after script loads showed only the existing stale enum reload warnings and no new touched-script parse errors. Final `play_scene main` launched the menu with desktop `MainMenuMusicPlayer` playback and `get_godot_errors` reported no session errors.
- Docs/wiki impact: `docs/architecture_review_tasks.md`, `docs/test_plan.md`, `wiki/known-issues.md`, `wiki/architecture.md`, `wiki/file-map.md`, `wiki/features.md`, and `wiki/log.md` updated for the resolved transition/HUD findings.

## Post-Review: FlowTrace And Callback Cleanup

- Status: `done`
- Owner/scope: Focused P1/P2 cleanup for confirmed architecture-review risks without changing combat math, mobile combat layout, shop economy, route semantics, debug command names, or visual timing. Scope includes bounded FlowTrace route retention, deferred rollback generation guards, `PlayerLoadoutHud` intent tween lifecycle cleanup, direct callable references in low-risk callback bindings, and removal of stable `RunState` transition API `has_method(...)` guards.
- Progress: 2026-05-06 completed the cleanup. `RunState` now caps retained FlowTrace route state at 50 routes while preserving the active route, exposes `flow_trace_debug_snapshot()` for focused probes, and tracks a transition generation that is bumped at prepared scene attach plus run mutation boundaries such as `start_new_run()` and `reset_run()`. Deferred prepared-scene post-ready callbacks now skip stale rollback restoration if a newer transition/run mutation happened during the one-frame health-check window. `PlayerLoadoutHud` now connects to the bound HUD section lifecycle and kills intent HP danger and armor-risk pulse tweens when that section exits. Low-risk `Callable(self, "...")` callback bindings were converted to direct callable references in combat, main-menu, collection, shop, and final-summary paths. Stable snapshot/restore and Collection FlowTrace wrapper guards now call the current `RunState` API directly; optional profile/meta/audio compatibility probes remain guarded.
- Out of scope:
  - Do not consolidate flow colors without a shared exact-match color owner.
  - Do not migrate UI to `.tscn` scenes, theme resources, or broader coordinator refactors.
  - Do not remove optional `has_method(...)` compatibility probes for profile/meta fallback names, dynamic audio nodes, or achievement toast APIs.
- Validation:
  - `git status --short --branch` confirmed branch `codex/milestone-12` with the focused source/doc changes; `git diff --check` passed.
  - Godot MCP `get_project_info` reported Godot `4.6.2-stable`; `view_script` passed for `run_state.gd`, `player_loadout_hud.gd`, `combat_player_controller.gd`, `main_boot.gd`, `collection.gd`, `final_run_summary.gd`, and `shop_player.gd`.
  - Focused FlowTrace probe created 65 synthetic routes and confirmed retained route count capped at `50`, active route id stayed present, `start_new_run()` bumped transition generation, and `reset_run()` bumped it again.
  - Focused scene instantiate probe passed for `main.tscn`, `combat_player.tscn`, `shop_player.tscn`, and `final_run_summary.tscn`.
  - Focused HUD lifecycle probe confirmed the new `PlayerLoadoutHud` cleanup callback is valid and can run when the bound HUD section exits.
  - Retained AR-01 combat result-envelope probe still matched baseline values under the nested `result` payload: `combo_count=3`, `heal_amount=4`, `armor_gained=9`, `gold_gained=2`, `enemy_blocked=5`, `enemy_damage_taken=19`, `total_elemental_damage=24`, `enemy_intent_skipped=false`, and `next_phase_name=Intent Preview`.
  - `play_scene main` launched with desktop `MainMenuMusicPlayer` playback; `stop_running_scene` succeeded; final `get_godot_errors` reported `Session has no errors`.
- Docs/wiki impact: `docs/architecture_review_tasks.md`, `docs/test_plan.md`, `wiki/known-issues.md`, `wiki/architecture.md`, `wiki/file-map.md`, and `wiki/log.md` updated for the cleanup and validation evidence.

## Milestone 12 Architecture Debt Follow-Up

### AR-19: Shop/content safety fixes

- Status: `done`
- Owner/scope: Harden shop pricing and content validation without changing prototype economy defaults beyond rejecting zero/negative shop multipliers. `ContentRegistry` now clamps `shop_price_multiplier` and `reroll_cost_multiplier` to at least `0.1`, exposes a conservative `reroll_cost_max` pricing field, and validates malformed player-state content entries without crashing. `ShopService` applies the same multiplier floor to item/reroll calculations, keeps positive reroll costs from rounding to zero, and respects the optional reroll ceiling.
- Validation:
  - Focused Godot MCP probe confirmed `shop_price_multiplier=0.1`, `reroll_cost_multiplier=0.1`, item price floor `1`, first positive reroll cost `1`, intentional zero-base reroll `0`, and bounded high reroll cost behavior.
  - Focused content validation probe confirmed non-dictionary entries and missing `next_tier_item_id` references report errors instead of crashing.

### AR-20: Shared flow result utilities

- Status: `done`
- Owner/scope: Added `scripts/core/flow_result_utils.gd` for common result/transition dictionary interpretation and replaced duplicated `_scene_change_succeeded(...)`, `_result_ok(...)`, and `_result_failure_reason(...)` helpers in main-menu, Collection, combat, shop, and run-summary controllers. Route semantics, rollback payloads, FlowTrace names, transition locks, and visible status text were preserved.
- Validation:
  - Focused Godot MCP helper probe confirmed the shared success/failure/reason matrix matches existing controller semantics.
  - Source search confirmed the duplicated private helper definitions were removed from the affected controllers.

### AR-21: Combat phase encapsulation

- Status: `done`
- Owner/scope: Added `CombatStateMachine.reset_to_intent_preview()` and replaced external direct writes to `_combat.phase = INTENT_PREVIEW` with the narrow method. Phase remains readable for current HUD/debug checks, and combat phase order, result envelopes, math, timing, and debug probes were not changed.
- Validation:
  - Source search confirmed no remaining external `_combat.phase = ...` writes while current phase reads remain intact.
  - Focused script reload checks covered `scripts/combat/combat_state_machine.gd` and `scripts/scenes/combat.gd`.

### AR-22: RunLogger extraction

- Status: `done`
- Owner/scope: Added `scripts/core/run_logger.gd` to own run-log event storage, serial allocation, metadata/export state, snapshots, run-end export assembly, and export bookkeeping. `RunState.run_log_*` public methods remain facade wrappers, and existing event names/payload shapes still flow through `RunLogReporter` for formatting.
- Validation:
  - Focused Godot MCP run-log probe confirmed a new run starts with `run_start`, preserves event count/order across snapshot/restore, and increments event count after a logged turn event.
  - Source search confirmed run-log backing state now lives in `RunLogger`, with `RunState` retaining only the delegated logger field and facade calls.

### AR-23: SceneRouter extraction

- Status: `done`
- Owner/scope: Added `scripts/core/scene_router.gd` to own FlowTrace route record storage, route retention, active route id, transition generation, prepared scene loading/attach helpers, rollback generation guards, and route debug snapshots. `RunState.flow_trace_*`, `next_scene_path()`, and transition-facing public APIs remain compatibility wrappers around the router.
- Validation:
  - Focused Godot MCP route probe confirmed route retention stays capped at `50`, the active route survives retention and snapshot/restore, and transition generation is preserved through router snapshot/restore.
  - Source search confirmed FlowTrace/transition backing state now lives in `SceneRouter`, with `RunState` retaining only the delegated router field and public facade.

- Multi-agent review: Explorer findings were accepted at `8.6/10`. The worker first pass was rejected at `7.4/10` because reroll pricing could still round to zero and extracted logger/router ownership was too shallow. The second worker pass fixed both blockers and was accepted at `8.7/10`.
- Shared validation:
  - `git status --short --branch` was checked before implementation/review batches on `codex/milestone-12`.
  - `git diff --check` passed.
  - Godot MCP `get_project_info` reported Godot `4.6.2-stable`.
  - Godot MCP `view_script` loaded the touched source scripts, including `run_state.gd`, `run_logger.gd`, `scene_router.gd`, `flow_result_utils.gd`, `content_registry.gd`, `shop_service.gd`, `combat_state_machine.gd`, and the affected controllers.
  - User manual QA passed on 2026-05-07 after the committed AR-19 through AR-23 batch.
- Docs/wiki impact: `docs/architecture_review_tasks.md`, `docs/test_plan.md`, `wiki/architecture.md`, `wiki/file-map.md`, `wiki/known-issues.md`, and `wiki/log.md` updated for the AR-19 through AR-23 architecture debt batch.

### AR-24: ProfileRepository extraction

- Status: `done`
- Owner/scope: Extract profile/meta-profile persistence from `scripts/core/run_state.gd` into a thin `scripts/core/profile_repository.gd` helper while keeping `RunState.profile_snapshot()`, `meta_profile_snapshot()`, `reset_profile()`, `create_default_profile()`, equipment unlock APIs, and Total Score APIs as the public compatibility boundary.
- Progress: 2026-05-07 completed the persistence-only extraction. `ProfileRepository` now owns profile path constants, `ConfigFile` load/save, legacy meta-profile migration from `user://matchatro_meta_profile.cfg`, save warnings, and last-I/O probe metadata. `RunState` keeps player/meta profile object ownership, default common unlock sync, equipment unlock/claim rules, victory unlock awards, Total Score banking, profile/meta public wrappers, and the reset-profile ordering.
- Plan:
  - Move `ConfigFile` load/save path ownership for `PROFILE_PATH`, `PROFILE_SECTION`, legacy `META_PROFILE_PATH`, and `META_PROFILE_SECTION` into `ProfileRepository`.
  - Keep `RunState` responsible for when profile/meta state is created, reset, synced with default unlocks, and exposed to callers.
  - Preserve legacy meta-profile migration behavior and existing profile snapshot shapes.
  - Avoid changing collection unlock rules, victory unlock awards, Total Score banking, profile overlay text, or save file locations.
- Validation:
  - `git status --short --branch` confirmed `codex/milestone-12`; `git diff --check` passed.
  - Godot MCP `get_project_info` reported Godot `4.6.2-stable`; `view_script` passed for `res://scripts/core/run_state.gd` and `res://scripts/core/profile_repository.gd`.
  - Focused Godot MCP editor probe with profile-file backup/restore confirmed reset/default common unlock sync, profile/meta snapshot shape, save/load round trip, legacy meta-profile migration, and recent unlock consume persistence behavior.
  - Godot MCP `play_scene main`, `stop_running_scene`, and `get_godot_errors` reported `Session has no errors`.
  - Multi-agent review: Explorer findings were accepted as the implementation boundary. Worker source patch was reviewed and accepted at `8.8/10`.
- Preserve:
  - Public `RunState` profile/meta APIs and return dictionary shapes.
  - Existing `user://matchatro_profile.cfg` and legacy `user://matchatro_meta_profile.cfg` behavior.
  - Common-equipment default unlock behavior.
  - Manual QA acceptance from AR-19 through AR-23 route flow.
- Docs/wiki impact: `docs/architecture_review_tasks.md`, `docs/test_plan.md`, `wiki/architecture.md`, `wiki/file-map.md`, and `wiki/log.md` updated for the new repository ownership.

### AR-25: BalanceManager extraction

- Status: `done`
- Owner/scope: Extract prototype balance lever normalization, defaults, project-setting sync, fight reward lookup, and encounter stat scaling from `scripts/core/run_state.gd` into `scripts/core/balance_manager.gd`. `RunState` remains the public facade for prototype balance APIs and current encounter assignment.
- Progress: 2026-05-07 completed the balance helper extraction. `BalanceManager` now owns prototype balance defaults, backing lever state, lever normalization, ProjectSettings sync, fight reward lookup, starting gold lookup, ContentRegistry lever propagation, and encounter HP/damage scaling. `RunState` keeps the public prototype balance facade methods, owns when active encounters are assigned, and still decides when scaling is applied.
- Plan:
  - Move `PROTOTYPE_BALANCE_DEFAULTS`, `PROTOTYPE_BALANCE_PROJECT_SETTINGS_PREFIX`, lever normalization, project-setting sync, level-scoped multipliers, encounter scaling, and fight gold reward lookup into `BalanceManager` unless a constant must stay in `RunState` for compatibility.
  - Keep `RunState.prototype_balance_levers_snapshot()`, `prototype_balance_defaults_snapshot()`, `set_prototype_balance_levers(...)`, `reset_prototype_balance_levers()`, and `prototype_fight_gold_reward_for(...)` wrappers.
  - Keep `RunState` as the owner of active encounter dictionaries and when scaling is applied during fight assignment.
  - Preserve temporary Milestone 10/M12 balance defaults except for safety clamps already introduced in AR-19.
- Validation:
  - `git status --short --branch` confirmed `codex/milestone-12`; `git diff --check` passed.
  - Godot MCP `view_script` passed for `res://scripts/core/run_state.gd` and `res://scripts/core/balance_manager.gd`.
  - Focused Godot MCP editor probes confirmed default snapshot parity, setter/resetter parity, ProjectSettings sync, fight rewards `10/12/14`, ContentRegistry shop/reroll multiplier propagation, first-shop guarantee path with `enemy_1` reward `10`, and representative encounter scaling.
  - Godot MCP `play_scene main`, `stop_running_scene`, and `get_godot_errors` reported no runtime errors.
  - Multi-agent review: Explorer findings were accepted as the implementation boundary. Worker source patch was reviewed and accepted at `8.7/10`.
- Preserve:
  - Existing public `RunState` balance method names and return shapes.
  - Current active encounter stats under default levers.
  - Current tuned temporary balance values and first-shop guarantee behavior.
  - Shop/content safety clamps from AR-19.
- Docs/wiki impact: `docs/architecture_review_tasks.md`, `docs/test_plan.md`, `wiki/architecture.md`, `wiki/file-map.md`, and `wiki/log.md` updated for the new balance helper ownership.

### AR-26: RunState signal facade

- Status: `done`
- Owner/scope: Add a small event-driven facade to `RunState` after logger/router/profile/balance ownership is stable. Initial signals should cover high-value state changes such as gold, level/step, run activity, profile/meta changes, and summary availability without forcing immediate controller migrations.
- Progress: 2026-05-07 completed the additive signal facade. `RunState` now exposes `gold_changed`, `run_step_changed`, `run_state_changed`, `profile_changed`, and `run_summary_changed` signals with dictionary payloads. Existing polling/snapshot APIs and controller call paths were left unchanged; the signals emit only from committed mutation points and snapshot restore emissions are marked with `restore_run_transition_state`.
- Plan:
  - Add conservative `RunState` signals such as `gold_changed`, `run_step_changed`, `run_state_changed`, `profile_changed`, and `run_summary_changed`.
  - Emit from existing mutation points only after state changes are committed.
  - Keep existing polling/snapshot APIs working; do not migrate all controllers in this batch unless a narrow caller benefits clearly.
  - Document signal payloads and avoid duplicate emissions during snapshot restore/rollback unless restoration intentionally changes visible state.
- Validation:
  - `git status --short --branch` confirmed `codex/milestone-12`; `git diff --check` passed.
  - Godot MCP `get_project_info`, `view_script` for `res://scripts/core/run_state.gd`, and `get_godot_errors` reported no session errors.
  - Focused Godot MCP editor probe connected all five signals and verified representative emissions for `start_new_run()`, `add_gold()`, successful and failed `spend_gold()`, fight victory, shop advance, snapshot restore, defeat/final summary, and reset.
  - Godot MCP `play_scene main`, `stop_running_scene`, and final `get_godot_errors` reported no runtime errors.
  - Multi-agent review: Explorer findings were accepted as the implementation boundary. Worker source patch was reviewed and accepted at `8.6/10`.
  - User manual QA passed on 2026-05-07 for the deferred AR-24 through AR-26 extraction batch.
- Preserve:
  - Public snapshot/polling APIs and current controller behavior.
  - Existing route semantics and rollback behavior.
  - RunLogger and SceneRouter facade boundaries introduced in AR-22 and AR-23.
- Docs/wiki impact: `docs/architecture_review_tasks.md`, `docs/test_plan.md`, `wiki/architecture.md`, `wiki/file-map.md`, and `wiki/log.md` updated for the signal facade.

### AR-27: Shared ConsoleLogger scene

- Status: `done`
- Owner/scope: Replace the combat-local log rendering part of `CombatDebugConsole` with a reusable `ConsoleLogger` scene. This is closed in the AR tracker as a non-launch future cleanup candidate; public-build debug exposure decisions are transferred to ITCH-06 in `docs/itch_readiness_tasks.md`.
- Plan:
  - Add a reusable console log UI scene, likely under `scenes/ui/`, with script ownership under `scripts/ui/`.
  - Add or choose a shared event boundary for console log events. Keep it narrow: append log line, clear log if needed, and optional level/category metadata.
  - Split current `CombatDebugConsole` responsibilities before renaming: command input and command dispatch remain combat-specific unless a later task creates a broader command router; log display moves to `ConsoleLogger`.
  - Preserve existing debug command names, command behavior, log visibility, and combat debug affordances during the migration.
- Validation:
  - Godot MCP instantiate check for the new reusable console scene and existing combat scene.
  - Focused probe that emits console log events from combat and at least one non-combat scene/controller surface.
  - Focused probe or manual QA that existing combat debug commands still dispatch and render log output in order.
  - `play_scene main`, `stop_running_scene`, and `get_godot_errors`.

### AR-28: Combat presenter naming cleanup

- Status: `done`
- Owner/scope: Aligned combat helper names with Rails-style presentation boundaries and avoided generic `Manager`/`Builder` names where the role is more precise. A presenter takes state, events, or result data and turns it into a consumable presentation object or presentation action for a view/UI surface. This was a naming/ownership pass only and did not intentionally change combat math, resolver envelopes, board coordinate handling, route semantics, or resolve replay timing.
- Progress: 2026-05-07 completed the behavior-preserving presenter rename pass. `CombatHudPresenter` now owns side-effect-free HUD display payload construction, `CombatTurnLogPresenter` owns readable combat turn/output text preparation, `CombatLayoutPresenter` owns combat scene layout presentation, and `CombatVfxPresenter` owns transient VFX presentation. Matching `.gd.uid` files moved with the renamed scripts, and direct runtime/debug references were updated.
- Plan:
  - Treat `Presenter` as the name for view-specific display preparation or sequencing.
  - Rename `CombatHudPresenter` for combat/player/enemy/run state prepared for HUD display.
  - Rename `CombatTurnLogPresenter` for text/output prepared for console or run-log presentation rather than owned storage.
  - Keep `Logger` for classes that own append/export/storage of log events. Do not use `Logger` for a class that only formats a turn result into display text.
  - Rename `CombatLayoutPresenter` for layout applied as a presentation concern.
  - Rename `CombatVfxPresenter` for combat events/results turned into visible VFX presentation.
- Validation:
  - Source-reference search found no old presenter/helper names across runtime/docs surfaces after docs sync.
  - `git diff --check` passed.
  - Godot MCP `get_project_info` reported Godot `4.6.2-stable`; `view_script` passed for `combat_controller.gd`, `combat_debug_console.gd`, `combat_hud_presenter.gd`, `combat_turn_log_presenter.gd`, `combat_layout_presenter.gd`, `combat_vfx_presenter.gd`, and `mobile_combat_layout_probe.gd`.
  - Godot MCP combat scene smoke ran through `open_scene res://scenes/combat.tscn`, `play_scene current`, and `stop_running_scene`.
  - Retained AR-01 combat result-envelope probe still matched the baseline values.
  - `get_godot_errors` still reported stale open-script/global-class diagnostics for deleted old presenter paths until the local `.godot` editor cache is fully refreshed; cache-ignore script loads and scene smoke used the renamed scripts successfully.

### AR-29: CombatView rendering ownership extraction

- Status: `done`
- Owner/scope: Continued the combat MVC refactor by moving view-only rendering ownership from `CombatController` into `CombatView`. This pass preserved combat math, resolver result envelopes, board-local `BoardView.gui_input` coordinates, route semantics, debug command behavior, `combat_speed`, and resolve/replay timing.
- Progress: 2026-05-07 completed the rendering extraction. `CombatView` now owns HUD snapshot application, top/enemy/timer/player/debug rendering, timer display sync, enemy intent bubble and enemy block preview rendering, hover signal emission, visual chrome, backdrop/scrim helpers, zone guides, loadout rail layout calls, and `CombatLayoutPresenter` application. `CombatController` remains the orchestrator for combat setup, HUD snapshot construction, shared HUD payload decisions, input phase authority, resolver kickoff, replay/VFX timing decisions, audio hooks, RunState/FlowTrace route calls, debug callbacks, `/skip`, and outcome routing.
- Follow-up: 2026-05-07 removed the leftover controller reach-ins to private `CombatView` helper nodes, dead render-only no-op wrappers, the public `CombatView.node(...)` accessor, and unused controller-owned intent/block preview declarations. `CombatView.refresh_character_portraits(...)` now owns portrait/backdrop refresh while controller references are limited closer to orchestration boundaries.
- Residual follow-up:
  - Reduce any remaining controller node references only where they are proven not to be needed for binding, VFX source-position decisions, signal callbacks, outcome/debug boundaries, or route/action buttons.
  - Keep `CombatModel` small until a separate state-ownership pass is planned.
- Validation:
  - Rendering extraction review gate accepted at `8.2/10`; score was capped by remaining compatibility wrappers and the blocked direct route probe.
  - Compatibility cleanup follow-up review gate accepted at `8.4/10`; score is capped by broader retained UI refs, stale editor reload warnings, and manual route/debug QA not being rerun in this pass.
  - `git diff --check` passed.
  - Godot MCP `get_project_info` reported Godot `4.6.2-stable`; `view_script` passed for `combat_controller.gd`, `combat_view.gd`, `combat_model.gd`, `combat_layout_presenter.gd`, `combat_vfx_presenter.gd`, `combat_resolve_presenter.gd`, and `board_controller.gd`.
  - Scene instantiate probe passed for `res://scenes/combat.tscn`, `res://scenes/main_menu.tscn`, `res://scenes/shop.tscn`, and `res://scenes/run_summary.tscn`.
  - Retained AR-01 combat result-envelope probe passed, and the focused board local-coordinate/touch drag probe preserved the board-local coordinate path.
  - `open_scene res://scenes/combat.tscn`, `play_scene main`, `stop_running_scene`, and final `get_godot_errors` passed with `Session has no errors`.
  - Direct route probing through MCP editor scripts could not execute because `RunState` was exposed as a placeholder instance in that context; manual route QA remains required.
  - Follow-up parser-crash fix removed invalid no-op compatibility statements and explicitly typed the `_view.apply_combat_layout(...)` result in `combat_controller.gd`; Godot MCP `play_scene current` reached `combat_first_usable_frame` and resolve trace output. User manual QA passed after the fix.
  - Compatibility cleanup follow-up validation passed `git status --short --branch`, `git diff --check` with the existing CRLF warning only, static searches for no-op assignments/untyped `_view` inference/private view-node calls/removed wrapper definitions, Godot MCP script loads, scene instantiate probes, retained AR-01 envelope probe, focused board local-coordinate/touch drag probe, `play_scene current`, resolve trace through match flash/clear/gravity/refill/final commit, `stop_running_scene`, and final `get_godot_errors` with no current crash. The editor session still reported stale unused-variable reload warnings, including declarations already removed by the follow-up patch.
  - User manual QA passed on 2026-05-07 for the compatibility cleanup follow-up, covering real drag, resolve animation feel, enemy intent/block preview hover rendering, victory/defeat/boss reward routes, and debug commands.

### AR-30: CombatModel scene-local state ownership

- Status: `done`
- Owner/scope: Continued the combat MVC refactor by moving scene-local mutable bookkeeping from `CombatController` into `CombatModel`. This pass intentionally kept `PlayerState`, `EnemyState`, `BoardModel`, `CombatStateMachine`, `RunState`, content registry state, resolver math, and replay timing outside `CombatModel`.
- Progress: 2026-05-07 completed the model ownership pass. `CombatModel` now owns input phase, external lock reason, `combat_speed`, FlowTrace route id, pending next-scene path, outcome transition lock, hovered board orb id, staged HUD replay values, combat mastery preview totals/token, and resolve trace active/origin/pass bookkeeping behind small methods. `CombatController` now calls model methods for those scene-local transitions and remains the owner of combat setup, resolver kickoff, board binding, audio, debug callbacks, RunState/FlowTrace side effects, route actions, and replay/VFX timing decisions.
- Preserve:
  - Combat math, resolver result shape, enemy intent resolution, reward values, route semantics, `combat_speed`, debug command names, board-local `BoardView.gui_input` coordinates, and visible resolve/replay timing.
  - Existing `CombatView` rendering ownership and presenter/helper boundaries.
- Validation:
  - Review gate accepted at `8.1/10`; score is capped because `CombatController` remains large, broad UI/presenter boundary refs remain, the editor session still reports reload-warning noise, and the full manual route/debug QA gate has not been rerun for this exact pass.
  - `git status --short --branch` confirmed `codex/milestone-12`; `git diff --check` passed with the existing CRLF normalization warning only.
  - Static searches confirmed moved state is no longer declared as controller-owned fields and model access is through method calls rather than direct public property mutation.
  - Godot MCP `get_project_info` reported Godot `4.6.2-stable`; `view_script` passed for `combat_model.gd`, `combat_controller.gd`, `combat_view.gd`, `combat_resolve_presenter.gd`, `combat_vfx_presenter.gd`, and `board_controller.gd`.
  - Scene instantiate probe passed for `res://scenes/combat.tscn`, `res://scenes/main_menu.tscn`, `res://scenes/shop.tscn`, and `res://scenes/run_summary.tscn`.
  - Retained AR-01 combat result-envelope probe and focused board local-coordinate/touch drag probe passed.
  - Initial `play_scene current` exposed a nil-model crash in `CombatController._enter_tree()` before `bind(...)`; a pre-bind `_ensure_model()` guard fixed it. The rerun reached `combat_first_usable_frame`, then `stop_running_scene` and final `get_godot_errors` reported no current runtime crash.
  - Exact-pass manual QA is closed in the AR tracker; release-candidate route/debug/manual QA is transferred to ITCH-03/ITCH-08 in `docs/itch_readiness_tasks.md`.

### AR-31: Combat layout presenter ownership cleanup

- Status: `done`
- Owner/scope: Continued the combat MVC cleanup by making `CombatView` the sole owner of `CombatLayoutPresenter` construction/binding and removing controller-side layout presenter compatibility storage. This pass preserved the existing presenter split: `CombatResolvePresenter` and `CombatVfxPresenter` stay controller-owned because the controller still chooses replay/VFX timing and source targets; `CombatTurnLogPresenter` stays controller-owned for debug/outcome text; `CombatHudPresenter` stays controller-owned for side-effect-free snapshot construction.
- Progress: 2026-05-07 removed `COMBAT_LAYOUT_PRESENTER_SCRIPT`, `_combat_layout_presenter`, `_bind_combat_layout_presenter()`, controller layout result mirrors, and the low-vertical-layout mirror from `CombatController`. `_apply_combat_layout()` now delegates to `CombatView.apply_combat_layout(...)` without storing view layout state.
- Preserve:
  - Combat math, resolver result shape, enemy intent resolution, reward values, route semantics, `combat_speed`, debug command names, board-local `BoardView.gui_input` coordinates, and visible resolve/replay timing.
  - Controller orchestration boundaries for board binding, resolve/VFX timing presenters, outcome overlay, debug console, signal/action callbacks, RunState/FlowTrace routing, audio, and privileged debug callbacks.
- Validation:
  - Review gate accepted at `8.3/10`; score is capped because broader controller UI refs remain at current orchestration/VFX/action boundaries, the live editor session still reports existing unused-field reload warnings, and full live resolve/manual route-debug QA was not rerun for this exact slice.
  - `git status --short --branch` confirmed `codex/milestone-12`; `git diff --check` passed with the existing CRLF normalization warning only.
  - Static searches confirmed removed layout presenter symbols/layout mirror fields are absent from `combat_controller.gd`, and found no standalone no-op statements or untyped controller `_view` inference sites.
  - Godot MCP `get_project_info` reported Godot `4.6.2-stable`; `view_script` passed for `combat_controller.gd`, `combat_view.gd`, `combat_model.gd`, `combat_layout_presenter.gd`, `combat_resolve_presenter.gd`, `combat_vfx_presenter.gd`, and `board_controller.gd`.
  - Scene instantiate probe passed for `res://scenes/combat.tscn`, `res://scenes/main_menu.tscn`, `res://scenes/shop.tscn`, and `res://scenes/run_summary.tscn`.
  - Retained AR-01 combat result-envelope probe and focused board local-coordinate/touch drag probe passed.
  - `open_scene res://scenes/combat.tscn`, `play_scene current`, `stop_running_scene`, and final `get_godot_errors` completed with no current runtime crash and the smoke reached `combat_first_usable_frame`. Existing unused-field reload warnings remain in the editor session.

### AR-32: Combat VFX target lookup cleanup

- Status: `done`
- Owner/scope: Continued combat MVC cleanup by moving enemy/player VFX target geometry lookup and VFX presenter binding-node packaging from `CombatController` into `CombatView`. This pass kept `CombatVfxPresenter` controller-owned and kept replay timing/order in `CombatController`.
- Progress: 2026-05-07 added `CombatView.enemy_vfx_target_global(...)`, `CombatView.player_vfx_target_global(...)`, and `CombatView.vfx_presenter_bindings(...)`. `CombatController` now asks the view for enemy/player replay targets and VFX binding nodes, with compatibility fallback to the existing controller refs. `_active_enemy_visual_control()` was removed because enemy target selection no longer needs a controller-owned helper.
- Preserve:
  - Combat math, resolver result shape, enemy intent resolution, reward values, route semantics, `combat_speed`, debug command names, board-local `BoardView.gui_input` coordinates, and visible resolve/replay timing.
  - Controller ownership of VFX timing decisions, replay waits, staged HUD updates, SFX calls, mastery feedback release, resolver callbacks, RunState/FlowTrace routing, and privileged debug callbacks.
- Validation:
  - Review gate accepted at `8.4/10`; score is capped because controller fallback node refs remain for compatibility and full manual route/debug QA was not rerun for this exact slice.
  - `git status --short --branch` confirmed `codex/milestone-12`; `git diff --check` passed with the existing CRLF normalization warning only.
  - Static searches confirmed `_active_enemy_visual_control` is absent, controller no longer directly computes centers from `_enemy_portrait` or `_player_portrait`, and the new `CombatView` VFX binding helper has explicit `Variant` local typing after an initial parser warning-as-error was found and fixed.
  - Godot MCP `get_project_info` reported Godot `4.6.2-stable`; `view_script` passed for `combat_controller.gd`, `combat_view.gd`, `combat_model.gd`, `combat_resolve_presenter.gd`, `combat_vfx_presenter.gd`, and `board_controller.gd`.
  - Scene instantiate probe passed for `res://scenes/combat.tscn`, `res://scenes/main_menu.tscn`, `res://scenes/shop.tscn`, and `res://scenes/run_summary.tscn`.
  - Retained AR-01 combat result-envelope probe and focused board local-coordinate/touch drag probe passed.
  - `open_scene res://scenes/combat.tscn`, `play_scene current`, `stop_running_scene`, and final `get_godot_errors` completed with no current runtime crash. Resolve trace reached match flash, clear, combo ticks, gravity/refill, animation drain, resolve completion, final board commit, and turn replay FlowTrace. Existing unused-field reload warnings remain in the editor session.
  - User manual QA passed on 2026-05-07 for this exact VFX target lookup cleanup.
