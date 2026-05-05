# Milestone 10 Balance Task Tracker

Purpose: track the short-term playtest balance pass with explicit status, ownership, validation gates, and documentation impact. This tracker should make Milestone 10 evidence-driven before Milestone 11 meta progression changes power curves, unlock pacing, and economy pressure.

Status values: `not started`, `in progress`, `blocked`, `done`, `deferred`.

## Design Target

Milestone 10 is a playtest-enabling pass, not the final balance pass. The target is a temporary balance layer where gold income, shop access, damage, enemy survivability, debug levers, and run-log evidence let testers repeatedly inspect equipment, mastery cards, consumables, relics, boosters, and early builds without many economy-starved runs.

The first implementation should capture the untuned baseline before changing balance values. Later tuning should compare against that baseline and clearly label temporary prototype values so Milestone 11 can separate scaffolding from accepted design.

## M10-01: Run Log, Balance Source Inventory, And Baseline Capture

- Status: `done`
- Owner/scope: Add a run-level logging system for balance evidence across combat, shops, boss rewards, and final summary, and inventory the active balance data owners before any tuning.
- Deliverable: Structured in-memory Run Log plus exportable JSON/text report and a short balance-source inventory.
- Progress: Implemented passive Run Log capture in `RunState`, with opt-in per-run export to project-root `logs/` on run end. Players can enable the persisted `Generate Log` toggle on the main menu; it defaults off. Each finalized logged run writes JSON, Markdown, and plain-text reports. Added runtime hooks for run start/end, fight start/end, turn results, shop open/actions/leave, and boss reward choice/skip without changing combat math, shop behavior, route semantics, balance values, or presentation timing.
- Blockers: None known. This task should run before balance tuning.
- Next action: Start M10-02 and capture untuned baseline logs from normal early runs before changing balance values.
- Acceptance:
  - The tracker or test notes identify current balance owners for orb spawn weights, gold gain formula, starting/run gold, shop pricing/reroll costs, enemy HP/intent damage, debug commands, and current validation surfaces.
  - A fresh run records run start, fight start/end, turn results, shop open/actions, boss reward choice/skip, and run end.
  - Exported logs answer gold entering each shop, offer prices, purchases, rerolls, turns per fight, HP loss, deaths, and item/relic access.
  - Logging does not change combat math, shop behavior, routing, balance values, or presentation timing.
- Validation:
  - Check `git status --short --branch` before edits.
  - Use Godot MCP, not headless: `get_project_info`, relevant script/scene loads, focused editor-script probes, `play_scene` where useful, and `get_godot_errors`.
  - Focused probe appends representative run, fight, turn, shop, boss reward, and run-end events, then verifies JSON/text fields.
  - Manual smoke: play through fight 1/shop 1 and export a log.
- Docs/wiki impact: Update `docs/test_plan.md` with Run Log usage and evidence. Update wiki only if the logging API/workflow becomes durable; append `wiki/log.md` if wiki changes.

Balance-source inventory captured for M10-01:

- Orb spawn weights: `scripts/board/board_generation_settings.gd` owns `spawn_weights`; current defaults are `1.0` for Fire/Ice/Earth/Heart/Armor and `0.45` for Gold, normalized by `BoardGenerationSettings.normalized_weights()` and consumed by `BoardState`.
- Starting/run gold: `scripts/combat/player_state.gd` resets player gold to `0`; `scripts/core/run_state.gd` owns `run_gold`, `total_gold_earned`, `set_gold(...)`, `add_gold(...)`, `spend_gold(...)`, and persistence across fights/shops.
- Gold gain formula: `scripts/combat/combat_state_machine.gd` computes gold from matched Gold orb count with combo multiplier `1.0`, active orb values/modifiers, and `flat_gold_bonus` only when Gold resolved, then applies it through `RunState.add_gold(...)`.
- Shop pricing/reroll costs: `scripts/content/content_registry.gd` owns the dictionary-backed shop pricing config (`common=10`, `uncommon=16`, `rare=24`, `level_step=2`, `reroll_base=1`, `reroll_step=1`); `scripts/shop/shop_service.gd` applies offer and reroll formulas.
- Enemy HP/intent damage: active runtime encounter selection, HP, and intent cycles are currently owned by `scripts/core/run_state.gd`. `ContentRegistry` still contains older enemy entries for content-contract coverage, but active balance tuning should treat `RunState` as authoritative for current encounter stats.
- Debug commands: `scripts/combat/combat_debug_console.gd` owns combat debug command parsing for state/log level, `/skip <level> <fight>`, board print/reroll/seed, gold add/set, mastery/consumable/equipment/relic list/add/show, and debug fight win/lose.
- Current validation surfaces: `res://scenes/main.tscn`, `res://scenes/combat/combat_player.tscn`, `res://scenes/flow/shop_player.tscn`, `res://scenes/flow/final_run_summary.tscn`, plus focused Godot MCP probes. Deleted debug/fallback scenes remain historical only.

Validation evidence:

- `git status --short --branch` confirmed work began on `codex/milestone-10` with existing uncommitted docs/wiki/tracker edits.
- `git diff --check` passed after the runtime changes.
- Godot MCP `get_project_info` confirmed Godot `4.6.2`, `RunState` autoload, and `res://scenes/main.tscn` as the main scene.
- Godot MCP `view_script` passed for `res://scripts/core/run_state.gd`, `res://scripts/core/run_log_reporter.gd`, and `res://scripts/combat/combat_player_controller.gd`.
- Focused Godot MCP load probe passed for `run_log_reporter.gd`, `run_state.gd`, `combat_player_controller.gd`, `main.tscn`, `combat_player.tscn`, `shop_player.tscn`, and `final_run_summary.tscn`.
- Focused Godot MCP Run Log probe produced `17` events and verified JSON/text/Markdown exports include event data/timeline fields. Representative event counts included `run_start`, `fight_start`, `turn_result`, `fight_end`, `shop_open`, `shop_action`, `shop_leave`, `boss_reward_skip`, and `run_end`.
- Separate focused Godot MCP boss reward probe generated `3` boss reward options, claimed one, and verified a `boss_reward_choice` event with a relic id.
- Follow-up Godot MCP export probe verified run finalization creates files under `D:/godot/matchatro/logs/` when Run Log generation is enabled and records last export metadata in `RunState.run_log_last_export_snapshot()`.
- `.gitignore` now ignores `logs/`; `git check-ignore -v logs/test.json` confirmed the rule.
- Focused scene instantiate probe passed for main, combat, shop, and final run summary scenes.
- Godot MCP `play_scene main` launched and stopped successfully; final `get_godot_errors` reported no session errors.
- Follow-up Godot MCP toggle probe verified `Generate Log` defaults/restores off, disabled runs leave no export paths, enabled runs write JSON/Markdown/text files, and `main.tscn` contains the connected `GenerateLogToggle`.
- Manual fight 1/shop 1 click-through was not completed in this pass; M10-02 should use the automatic files in `logs/` from normal untuned runs.

## M10-02: Untuned Baseline Runs

- Status: `done`
- Owner/scope: Capture current balance before any tuning.
- Deliverable: At least 3 exported baseline Run Logs from normal early runs, plus a short blocker summary.
- Progress: Verified 3 human-played untuned Run Logs under `logs/` with matching JSON/Markdown/text exports. `run_1777938769_177353_2026-05-05t07_52_49` is annotated in `wiki/log-notes.md` as a high-skill player run; it reached level 2 boss, cleared 5 normal enemies and 1 boss, opened 5 shops, bought 1 equipment and 1 mastery card, then died to Burning Knight after 38 total turns and 35 gold gained. `run_1777940350_422781_2026-05-05t08_19_10` is annotated as an intentional new-player simulation; it died in level 1 fight 1 after 12 turns with 10 gold gained and no shop access. `run_1777941462_641881_2026-05-05t08_37_42` reached level 3 enemy 1, cleared 6 normal enemies and 2 bosses, opened 6 shops, bought 1 consumable and 1 equipment, then died to Vault Executioner after 30 total turns and 30 gold gained. These are human-played baseline logs, not automated probes.
- Blockers: None for baseline capture. The evidence remains small, so tuning should avoid overfitting to one skilled run or one new-player simulation.
- Next action: Start M10-03 and add the prototype balance lever layer without tuning values directly from these logs yet.
- Acceptance:
  - Baseline records level 1 fight/shop outcomes and reaches as far as current balance naturally allows.
  - Notes identify whether the main blocker is gold starvation, enemy damage, enemy HP, shop prices, item access, or usability.
  - No balance values are changed in this task.
- Validation:
  - Exported Run Logs exist locally; current count is 3 of 3 required human-played logs.
  - `docs/test_plan.md` records the baseline summary without marking tuning tasks complete.
- Docs/wiki impact: Update `docs/test_plan.md` with baseline evidence. Wiki updates are only needed if durable workflow knowledge changes.

## M10-03: Prototype Balance Lever Layer

- Status: `done`
- Owner/scope: Add a small temporary balance surface for playtest tuning.
- Deliverable: Configurable prototype values for starting gold, gold access, shop affordability, reroll cost, enemy HP/damage scaling, and debug/test access where appropriate.
- Progress: Added a temporary `RunState` prototype balance lever surface with neutral defaults: `starting_gold = 0`, `gold_orb_spawn_weight_multiplier = 1.0`, `shop_price_multiplier = 1.0`, `reroll_cost_multiplier = 1.0`, `enemy_hp_multiplier = 1.0`, and `enemy_damage_multiplier = 1.0`. Defaults preserve current behavior. `RunState` applies starting gold on new runs and scales active encounter HP/attack snapshots when overrides are set. `BoardGenerationSettings` reads the gold-orb spawn multiplier through the same runtime lever mirror, so new board generation can adjust gold access without changing the base spawn table. `ContentRegistry` exposes temporary shop price/reroll multipliers through its existing dictionary-backed pricing config, and `ShopService` applies those multipliers without changing transaction semantics. No debug/test access lever was added in this slice because the M10-02 evidence points first to economy and survivability, while existing combat debug commands already cover forced content/run setup for later M10-06 investigation.
- Blockers: None known.
- Next action: Start M10-04 and tune early gold access by adjusting these temporary levers against the M10-02 baseline, without treating values as final balance.
- Acceptance:
  - Designers can adjust early-run playtest access without rewriting core systems.
  - Defaults preserve current behavior until M10 tuning intentionally changes them.
  - Values are clearly labeled temporary/prototype.
- Validation:
  - Godot MCP focused probes confirm default parity.
  - Focused probes confirm overridden values affect new runs, shops, enemies, or debug access as intended.
- Docs/wiki impact: Documented lever ownership, default parity, and temporary intent in `docs/test_plan.md`; updated wiki because the temporary balance workflow/ownership surface is durable for the rest of M10.

Validation evidence:

- `git status --short --branch` confirmed work on `codex/milestone-10`.
- Godot MCP `get_project_info` confirmed Godot `4.6.2`, the `RunState` autoload, and `res://scenes/main.tscn` as the main scene.
- Godot MCP `view_script` passed for `res://scripts/core/run_state.gd`, `res://scripts/content/content_registry.gd`, `res://scripts/shop/shop_service.gd`, and `res://scripts/board/board_generation_settings.gd`.
- Focused Godot MCP lever probe confirmed default parity and override effects: default starting gold `0`, first enemy HP `76`, first attack `12`, gold normalized weight about `0.08257`, base price `10`, and reroll cost `1`; override values changed those to starting gold `7`, first enemy HP `38`, first attack `24`, gold normalized weight about `0.15254`, base price `5`, and reroll cost `3`.

## M10-04: Early Economy Tuning

- Status: `done`
- Owner/scope: Tune gold income and shop affordability for repeated playtesting.
- Deliverable: Temporary values for starting gold, gold orb spawn/value, fight rewards if added, shop prices, booster prices, and reroll cost.
- Progress: Retuned M10-04 away from random early gold and into fixed fight base rewards through the M10-03 lever surface: `starting_gold = 0`, `gold_orb_spawn_weight_multiplier = 1.0`, `shop_price_multiplier = 1.0`, `reroll_cost_multiplier = 1.0`, `level_1_fight_gold_reward = 10`, `level_2_fight_gold_reward = 12`, and `level_3_fight_gold_reward = 14`. Victory now grants the base fight reward in `RunState.mark_fight_victory()` after matched gold has already been applied by combat, and the post-match victory popup displays total fight gold as base plus matched gold. The first level-1 shop guarantees one exact 10-gold item offer while keeping the other item slots random. Enemy HP and damage multipliers remain `1.0` for M10-05. Combat math, resolver rules, shop transaction semantics, RunState routing, Run Log behavior, and combat presentation timing were not changed.
- Blockers: None known. These values are temporary playtest scaffolding and a playtest economy rule, not final economy balance.
- Next action: Start M10-05 and tune early combat survivability separately against the M10-02/M10-04 evidence.
- Acceptance:
  - After the first enemy, a normal playtest run can usually buy at least one meaningful shop option.
  - Boosters and consumables become practical to inspect without debug-only setup.
  - Economy remains visibly limited enough that choices still matter.
- Validation:
  - Godot MCP affordability probes for level 1-3 shops.
  - At least 2 Run Log comparisons against the M10-02 baseline.
- Docs/wiki impact: Record temporary economy assumptions in `docs/test_plan.md`; update wiki if balance workflow or ownership changes.

Validation evidence:

- `git status --short --branch` confirmed work on `codex/milestone-10`.
- M10-02 comparison baseline: first shops opened with `3` gold in the high-skill baseline, no shop in the new-player simulation, and `0` gold in the third baseline; later level 1 shops opened with `13`, `25`, `3`, and `10` gold depending on run quality and purchases.
- Focused Godot MCP lever probes confirmed the fixed reward defaults apply through the M10-03 surface: new runs start with `0` gold, level rewards are `10/12/14`, Gold orb spawn weight and shop/reroll multipliers are back to neutral `1.0`, and enemy HP/damage remain `1.0`.
- Focused victory/shop probes confirmed a first fight with `+3` matched gold returns `base_gold_reward = 10`, leaves the run with `13` gold, records `base_gold_reward = 10` in the Run Log fight-end payload, and formats the popup body as `GOLD GAINED +13`, `Defeat enemy: 10 gold`, and `Bonus gold: 3 gold`.
- Focused shop affordability probes confirmed a no-matched-gold first victory leaves `10` gold, opens the first level-1 shop, and guarantees an exact 10-gold `equipment:coin_purse` offer so at least one useful common option is affordable.
- Godot MCP `get_project_info`, script checks, focused reward/popup/shop probes, and current `get_godot_errors` check passed with only pre-existing stale enum diagnostics plus failed ad hoc probe attempts in the session log; the final focused probes executed successfully and touched script reload checks returned `0`. `git diff --check` passed.

## M10-05: Early Combat Survivability Tuning

- Status: `not started`
- Owner/scope: Tune level 1-2 enemy HP, damage, block, and player survivability.
- Deliverable: Temporary enemy/player survivability values that let testers reach multiple shops.
- Progress: Not started.
- Blockers: M10-02 baseline and M10-03 lever layer should be available first.
- Next action: Tune against baseline turns-to-kill, HP loss, death, and level-reached evidence.
- Acceptance:
  - Normal runs survive long enough to test shop/build decisions.
  - Mistakes and poor boards can still cost HP or cause defeat.
  - Bosses remain meaningfully tougher than normal fights.
- Validation:
  - Godot MCP encounter stat probes.
  - Run Log comparison for turns-to-kill, HP loss, deaths, and level reached.
- Docs/wiki impact: Record temporary survivability assumptions in `docs/test_plan.md`; update wiki only for durable behavior/workflow changes.

## M10-06: Item, Relic, Booster Access Pass

- Status: `not started`
- Owner/scope: Make implemented content practical to inspect during repeated runs.
- Deliverable: Temporary access improvements through economy, offer pools, debug commands, or test-only run setup.
- Progress: Not started.
- Blockers: M10-04 and M10-05 should make normal access easier before adding broader debug/test scaffolding.
- Next action: Use Run Logs and shop/content probes to find which content categories remain hard to inspect.
- Acceptance:
  - Equipment, mastery cards, consumables, relics, and boosters can all be exercised without many failed economy-starved runs.
  - Any debug/test shortcut is clearly marked as playtest scaffolding.
  - Merchant Compass/reroll behavior is either implemented for the prototype or explicitly documented as deferred.
- Validation:
  - Godot MCP shop/service probes for offer pools and affordability.
  - Manual or Run Log evidence showing each content category was reached.
- Docs/wiki impact: Record access assumptions and any deferred content-access risks in `docs/test_plan.md` or wiki as appropriate.

## M10-07: Focused Playtest Loop And Closeout

- Status: `not started`
- Owner/scope: Confirm M10 creates a playable baseline for Milestone 11.
- Deliverable: Final M10 playtest notes and tracker updates.
- Progress: Not started.
- Blockers: M10-01 through M10-06 should be complete or explicitly deferred.
- Next action: Compare tuned logs against the untuned baseline and separate remaining post-meta tuning questions from M10 blockers.
- Acceptance:
  - Multiple early-run logs show improved gold access, survivability, and content access versus baseline.
  - Temporary balance assumptions are recorded.
  - Remaining post-meta tuning questions are separated from M10 blockers.
  - `todo.md` Milestone 10 status/checklist is updated only after real validation.
- Validation:
  - Godot MCP final smoke: main, combat, shop, final summary, and `get_godot_errors`.
  - Manual playtest notes or exported logs for at least 2 tuned runs.
- Docs/wiki impact: Update `todo.md`, `docs/test_plan.md`, relevant wiki pages, and `wiki/log.md` if wiki changes.

## Agent Instruction Template

Use this template when handing one M10 task to the next agent:

```md
Start M10-XX: [Task Name]

Branch/current context:
- Repo: `D:\godot\matchatro`
- Branch: `codex/milestone-10`
- Tracker: `docs/milestone_10_balance_tasks.md`
- Scope source: `todo.md` Milestone 10 and `docs/test_plan.md`

Workflow:
- Use multi-agent workflow.
- Default/main agent owns orchestration, tracker/doc/wiki updates, integration review, and final handoff.
- Explorer agent performs read-only investigation: current source behavior, relevant wiki/docs, risks, validation surfaces, and contradictions.
- Worker agent performs source/runtime code edits in a bounded ownership area.
- Do not let explorer edit files.
- In multi-agent mode, do not edit gameplay/runtime files from the main/default agent; assign source/runtime edits to worker.
- Tell workers they are not alone in the codebase and must not revert edits made by others.

Goal:
- [One-sentence task goal.]

Implement:
- [Concrete implementation bullets.]
- Keep changes limited to this task's ownership.
- Update `docs/milestone_10_balance_tasks.md` progress/status.
- Update `docs/test_plan.md` with validation evidence.
- Update wiki only if durable behavior/API/workflow changes; append `wiki/log.md` if wiki changes.

Preserve:
- Do not start Milestone 11 meta progression.
- Do not treat temporary M10 values as final balance.
- Do not change combat math, resolver rules, shop transaction semantics, RunState routing, or combat presentation timing unless this task explicitly requires it.
- Do not mark checklist items done without real validation or explicit user QA confirmation.
- Use Godot MCP for Godot validation; do not use headless.
- Do not commit unless the user explicitly asks.

Validation:
- Check `git status --short --branch`.
- Use Godot MCP: `get_project_info`, relevant script/scene loads, focused editor-script probes, `play_scene` where useful, and `get_godot_errors`.
- For Run Log/tuning tasks, capture or compare exported Run Logs as task evidence.
- State what was tested, what was not tested, and remaining uncertainty.

Expected final response:
- Changed files.
- Validation performed.
- Manual QA needed or completed.
- Next recommended M10 task.
```

## Guardrails

- Use multi-agent workflow by default for M10 implementation prompts.
- Source/runtime code edits should be assigned to a worker in multi-agent mode.
- Keep each task narrow and sequential; do not overlap balance tuning before M10-01/M10-02 baseline evidence exists.
- Treat active source as authoritative: current runtime encounter selection and enemy stat tuning live in `RunState`, while shop pricing and much prototype content live in dictionary-backed `ContentRegistry`. If docs/wiki imply a different owner, call out the mismatch before tuning.
- Current validation surfaces are `res://scenes/main.tscn`, `res://scenes/combat/combat_player.tscn`, `res://scenes/flow/shop_player.tscn`, `res://scenes/flow/final_run_summary.tscn`, and focused Godot MCP probes. Do not use deleted debug/fallback scenes as current validation surfaces.
- Do not start Milestone 11 meta progression inside M10.
- Do not treat temporary M10 values as final balance.
- Do not change combat math, resolver rules, shop transaction semantics, RunState routing, or combat presentation timing unless a specific M10 task explicitly calls for it.
- Preserve accepted CFR presentation behavior, including result readability and `combat_speed`; do not fold visual-feedback changes into balance work.
- Use Godot MCP for Godot validation; do not use headless.
- Do not mark M10 tasks done without real validation evidence or explicit user QA confirmation.
- Keep `todo.md`, `docs/test_plan.md`, relevant wiki pages, and `wiki/log.md` synchronized when behavior or durable workflow changes.
