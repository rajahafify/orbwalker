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

- Status: `deferred`
- Owner/scope: Resolve animation and presentation helpers currently concentrated in `scripts/combat/combat_player_controller.gd`.
- Progress: Not started; deferred until the first controller split proves the extraction pattern.
- Blockers: Depends on AR-05 and visual regression checks. Must preserve accepted presentation order.
- Next action: Inventory presentation-only helpers and define a boundary that keeps resolver math untouched.
- Validation: Visible order remains `drag finish -> match flash -> clear animation -> COMBO x1 / mastery preview -> gravity -> refill`; cascade combo/mastery feedback remains stable; scene smoke and focused replay probes pass.
- Docs/wiki impact: Update `wiki/features.md`, `wiki/architecture.md`, `wiki/file-map.md`, and `docs/test_plan.md` if ownership changes.

## AR-07: RunState/Data Contract Roadmap

- Status: `deferred`
- Owner/scope: `scripts/core/run_state.gd`, `scripts/content/content_registry.gd`, `docs/system_architecture.md`, and future content data format.
- Progress: Dictionary-backed live content and Resource-based architecture docs are confirmed to diverge.
- Blockers: Needs a design decision on `.tres` versus JSON or an explicit decision to keep dictionary-backed content for the prototype.
- Next action: Choose and document the content source-of-truth direction, then plan a compatibility layer that keeps `ContentRegistry` as the read API during migration.
- Validation: Runtime content loading, `docs/system_architecture.md`, `wiki/architecture.md`, and `wiki/file-map.md` all describe the same current/future split; shop/content probes still pass.
- Docs/wiki impact: Update `docs/system_architecture.md`, `wiki/architecture.md`, `wiki/file-map.md`, `wiki/known-issues.md`, and `wiki/log.md`.

## AR-08: Cleanup/Dead-Code Validation

- Status: `not started`
- Owner/scope: Confirmed-unused symbols and stale placeholder/fallback surfaces such as `base_orb_values`, `PLAYER_EFFECT_ORDER`, summary helpers, and legacy placeholder scenes.
- Progress: Candidates are identified, but no removal is tracked here.
- Blockers: Requires reference checks and scene validation before deletion. Legacy/debug fallback usage must be confirmed before removing placeholder scenes.
- Next action: Run reference searches and scene-route checks for one cleanup candidate at a time.
- Validation: No references remain; relevant scenes instantiate/run; `get_godot_errors` stays clean; docs/wiki no longer point to removed fallback surfaces.
- Docs/wiki impact: Update `todo.md`, `docs/test_plan.md`, `wiki/file-map.md`, `wiki/known-issues.md`, and `wiki/log.md` when cleanup changes durable project knowledge.
