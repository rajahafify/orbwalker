# Architecture Review Task Tracker

Purpose: track architecture-review follow-up work with explicit status, progress, blockers, validation gates, and documentation impact. This is the entry point for architecture-maintenance tasks before Milestone 10 balance closure.

Status values: `not started`, `in progress`, `blocked`, `done`, `deferred`.

## AR-01: Baseline Regression Harness

- Status: `not started`
- Owner/scope: Regression checklist and Godot MCP probe workflow for board resolver, combat state machine, shop service, RunState routing, audio loading, and shared HUD selection.
- Progress: No baseline has been captured in this tracker yet.
- Blockers: Needs a current static/Godot MCP baseline before any behavior-preserving refactor starts.
- Next action: Capture `git status --short --branch`, `git diff --check`, `get_project_info`, `get_godot_errors`, key scene smokes, and focused probe outputs as the baseline evidence.
- Validation: Static checks pass; Godot MCP checks cover `res://scenes/main.tscn`, `res://scenes/combat/combat_player.tscn`, `res://scenes/combat/board_debug.tscn`, and `res://scenes/flow/shop_player.tscn`; focused probes record expected result envelopes for deterministic systems.
- Docs/wiki impact: Update `docs/test_plan.md` with dated baseline results and mirror durable gaps in `wiki/known-issues.md`.

## AR-02: Low-Risk Bug Fixes

- Status: `not started`
- Owner/scope: Small confirmed issues such as `EnemyState.get_current_intent()` mutation, main-menu music polling after success, noisy audio diagnostics, and await/transition guards.
- Progress: Issues are identified from review, but no fixes are tracked here.
- Blockers: Depends on AR-01 baseline so small fixes can be regression-checked.
- Next action: Pick one confirmed bug, implement it as a narrow patch, and compare focused probe output against the baseline.
- Validation: Relevant focused probe passes, `get_godot_errors` is clean or stale diagnostics are called out, and affected scene smoke still works.
- Docs/wiki impact: Update `docs/test_plan.md` verification notes and `wiki/known-issues.md` only when a durable risk is resolved or newly discovered.

## AR-03: Shared WAV/Audio Utility Extraction

- Status: `not started`
- Owner/scope: Shared WAV parsing, frame-count, and loop configuration logic currently duplicated between `scripts/core/audio_manager.gd` and `scripts/core/main_boot.gd`.
- Progress: Duplication is confirmed; no extraction has been performed.
- Blockers: Requires audio regression checks for menu, combat, shop, generated SFX, Android/template raw WAV fallback, and manual/on-device listening gaps.
- Next action: Define the shared utility API and write pre-change audio loading probes before moving any code.
- Validation: Godot MCP audio stream probes pass for menu/combat/shop WAVs; generated `swap` SFX still builds; main and combat scene smokes show the expected music source diagnostics; Android listening remains explicitly marked if not retested.
- Docs/wiki impact: Update `docs/test_plan.md`, `wiki/features.md`, `wiki/file-map.md`, and `wiki/known-issues.md` if ownership changes.

## AR-04: Shop/Input Safety

- Status: `not started`
- Owner/scope: `scripts/flow/shop_player.gd`, `scripts/shop/shop_service.gd`, and shared `scripts/ui/player_loadout_hud.gd` interaction behavior.
- Progress: Risks are identified: duplicate transaction taps and hover/click/touch selection conflation need focused validation.
- Blockers: Needs shop/player HUD interaction probes and, for touch acceptance, on-device validation.
- Next action: Add a focused regression checklist for buy/reroll/sell/booster actions and shared HUD slot selection before implementation.
- Validation: Shop actions produce one result per press; buy/reroll/sell/booster paths remain usable; equipment/consumable slot selection survives hover exit and works with click/touch semantics; outside-click dismissal still works.
- Docs/wiki impact: Update `docs/test_plan.md`, `wiki/features.md`, and `wiki/known-issues.md` when behavior or validation status changes.

## AR-05: Combat Controller First Split

- Status: `deferred`
- Owner/scope: First behavior-preserving extraction from `scripts/combat/combat_player_controller.gd`, preferably debug console or outcome/boss reward overlay ownership before presentation timing.
- Progress: Not started; deferred until stabilization and baseline coverage exist.
- Blockers: Depends on AR-01 baseline plus low-risk stabilization. Source/runtime code edits should be worker-owned in multi-agent mode.
- Next action: Select one narrow non-overlapping responsibility and define the new helper/controller boundary without changing combat math or visible resolve order.
- Validation: Full combat route smoke passes for victory, defeat, boss reward claim/skip, post-boss shop, and final-boss summary; `get_godot_errors` remains clean.
- Docs/wiki impact: Update `wiki/file-map.md`, `wiki/architecture.md`, and `docs/test_plan.md` if file responsibilities change.

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
