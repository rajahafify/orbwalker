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

- Status: `done`
- Owner/scope: Tune level 1-2 enemy HP, damage, block, and player survivability.
- Deliverable: Temporary enemy/player survivability values that let testers reach multiple shops.
- Progress: Added level/type-scoped temporary survivability levers through the M10-03 prototype balance surface while keeping the existing global enemy HP/damage multipliers neutral at `1.0`. Current temporary M10-05 defaults make Dungeon 1 a forgiving damage check where enemies defend often: a player making at least one basic combo per turn should be able to clear the two normal fights, but failing at the Dungeon 1 boss is acceptable because Iron Gate is the first skill check. Level 1 normal HP is `0.50` and damage `0.50`; level 1 boss HP is `0.60` and damage `0.65`. Dungeon 2 is now the first defense check: level 2 normal HP `0.90` and damage `1.0`, level 2 boss HP `1.0` and damage `1.10`, with fewer block-heavy turns and stronger/more frequent attacks. Dungeon 3 is now a late damage check after a high-effort run showed it collapsing too quickly: level 3 normal HP/damage is `2.2/1.20`, and level 3 boss HP/damage is `2.60/1.30`. These values are prototype playtest scaffolding, not final balance. Combat math, resolver behavior, shop behavior, RunState routing, Run Log behavior, combat presentation timing, and M10-04 fixed fight-gold reward/popup behavior were not changed.
- Blockers: None known. Human playtest feedback on 2026-05-05 accepted the current early-balance state for now; deeper rebalance should wait until after Milestone 11 meta progression changes the power curve.
- Next action: Start M10-06 and check item/relic/booster access against the M10-04 economy floor plus the M10-05 early survivability values.
- Acceptance:
  - Normal runs survive long enough to test shop/build decisions.
  - Mistakes and poor boards can still cost HP or cause defeat.
  - Bosses remain meaningfully tougher than normal fights.
- Validation:
  - Godot MCP encounter stat probes.
  - Run Log comparison for turns-to-kill, HP loss, deaths, and level reached.
- Docs/wiki impact: Record temporary survivability assumptions in `docs/test_plan.md`; update wiki only for durable behavior/workflow changes.

Validation evidence:

- `git status --short --branch` confirmed work on `codex/milestone-10`.
- M10-02 comparison baseline: the new-player simulation died in level 1 fight 1 after `12` turns, the high-skill run died at the level 2 boss after `38` total turns, and the third baseline died at level 3 enemy 1 after `30` total turns. Existing M10-04-era local logs remained mixed after economy tuning, with examples including level 1 fight 1 defeats, a level 1 boss defeat, level 2 enemy defeats, and one full victory, so the first survivability pass avoids final-value claims.
- Focused Godot MCP encounter-stat probe confirmed current defaults express the intended dungeon identities: L1F1 became `38 HP`, `0/5/6 attack`, and `8/6/0 block`; L1F2 became `41 HP`, `0/4/5 attack`, and `12/9/0 block`; L1 boss became `85 HP`, `0/9/10 attack`, and `20/12/0 block`. L2F1 is now `85 HP`, `16/14/18 attack`, and `0/3/0 block`; L2F2 is now `88 HP`, `18/16/15 attack`, and `0/0/2 block`; L2 boss is now `158 HP`, `26/24/20 attack`, and `0/0/4 block`. After the late-dungeon retune, L3 normal HP/damage multipliers are `2.2/1.20` and L3 boss HP/damage multipliers are `2.60/1.30`, raising Vault Executioner from `112` to about `246 HP` and Prism Warden from `176` to about `458 HP`.
- Focused math check confirmed a mastery-0 basic 3-orb elemental match with `1` combo deals `3` damage before enemy block. The new level 1 HP/damage values are intentionally forgiving for that low-skill floor, while the level 1 boss remains tougher through higher HP and existing block.
- Focused Godot MCP guard probes confirmed level rewards remain `10/12/14` and a first fight victory with no matched gold still grants `10` base gold. Later M10-05 Dungeon 3 changes were limited to the level 3 HP/damage temporary levers.
- Focused Godot MCP scoped override probe confirmed changing `level_2_boss_damage_multiplier` affected only level 2 boss attacks, without leaking to level 2 normal enemies or level 3 boss.
- Tuned human-played Run Log comparison `run_1777962841_273458_2026-05-05t14_34_01` cleared level 1 and reached level 2 boss without debug flow. It cleared L1 enemy 1 in `4` turns, L1 enemy 2 in `21` turns, L1 boss in `11` turns, L2 enemy 1 in `15` turns, and L2 enemy 2 in `7` turns before dying to Burning Knight on L2 boss turn `3`. The run opened five shops, bought five equipment items, bought one booster, claimed one mastery-card booster option, bought another mastery card, chose `Stalwart Mantle`, and ended with `7` gold. This supports the level 1 survivability target, but L1 enemy 2 remains a possible pacing concern because it took `21` turns at about `1.29` average combos per turn.
- Tuned one-combo-focused Run Log `run_1777966488_296058_2026-05-05t15_34_48` cleared L1 enemy 1 in `12` turns and L1 enemy 2 in `9` turns, then died to Iron Gate on boss turn `17` with the boss still at `67/85 HP`. This is accepted for the current target: one-combo play can clear the normal fights, but the boss may defeat a player who does not improve damage output.
- Tuned high-effort Run Log `run_1777967813_853019_2026-05-05t15_56_53` cleared the run, but Dungeon 3 was too weak for a strong player: Vault Executioner died in `2` turns with `0` HP loss, Goldbound Keeper died in `1` turn with `0` HP loss, and Prism Warden died in `1` turn with `0` HP loss. That evidence triggered the level 3 HP/damage lever increase above. Follow-up Run Logs `run_1777968781_770133_2026-05-05t16_13_01` and `run_1777969048_434533_2026-05-05t16_17_28` showed the retuned Dungeon 3 can both kill a run at Vault Executioner and still allow a strong full victory with longer D3 fights. The player accepted this as fine for early balance and deferred deeper rebalance until after meta progression.
- Godot MCP `get_project_info`, `view_script` for `res://scripts/core/run_state.gd`, focused stat/economy/override probes, current `get_godot_errors` checks, and `git diff --check` passed. One probe using normal `load(...)` saw stale cached script values; rerunning with `ResourceLoader.CACHE_MODE_IGNORE` confirmed the current identity values.

## M10-06: Item, Relic, Booster Access Pass

- Status: `done`
- Owner/scope: Make implemented content practical to inspect during repeated runs.
- Deliverable: Temporary access improvements through economy, offer pools, debug commands, or test-only run setup.
- Progress: Completed a scoped shop-access rebalance after review found the content categories needed a clearer prototype shape. Normal shop item offers now guarantee at least one booster when boosters are available, bias the remaining offers toward equipment, keep mastery cards possible, make consumables rare, and avoid a second booster unless no non-booster option remains. The first level-1 shop now guarantees affordable damage equipment via `Shortsword` instead of `Coin Purse`; `Shortsword` price was reduced from `12` to the `10` gold first-fight floor. Shop relic offers now persist as one relic per dungeon level: later same-level shops show the bought relic as sold out instead of rolling a replacement, while the next dungeon level rolls a new relic offer.
- Blockers: None for M10-06. Merchant Compass free-first-reroll behavior remains explicitly deferred; reroll still uses the existing paid reroll path.
- Next action: Start M10-07 and close out Milestone 10 with focused playtest comparison notes, while keeping deeper rebalance and meta-progression content access for Milestone 11 or later.
- Acceptance:
  - Equipment, mastery cards, consumables, relics, and boosters can all be exercised without many failed economy-starved runs.
  - Any debug/test shortcut is clearly marked as playtest scaffolding.
  - Merchant Compass/reroll behavior is either implemented for the prototype or explicitly documented as deferred.
- Validation:
  - Godot MCP shop/service probes for offer pools and affordability.
  - Manual or Run Log evidence showing each content category was reached.
- Docs/wiki impact: Record access assumptions and any deferred content-access risks in `docs/test_plan.md` or wiki as appropriate.

Validation evidence:

- `git status --short --branch` confirmed work on `codex/milestone-10`.
- Explorer read-only pass found current shop pools include equipment, consumables, mastery cards, and boosters; booster prices are `9` and `10`; shop relic offers filter owned relics; boss rewards offer unowned relics first; and Merchant Compass free-first-reroll is still not implemented/deferred. Follow-up design review changed M10-06 from evidence-only into a scoped offer-mix and relic-persistence rebalance.
- Tuned Run Log comparison showed content access across recent M10-05 accepted runs. `run_1777962841_273458_2026-05-05t14_34_01` opened five shops, bought five equipment items, bought one booster, claimed one mastery-card booster option, bought another mastery card, chose `Stalwart Mantle`, and ended with `7` gold. `run_1777969048_434533_2026-05-05t16_17_28` was a full victory with eight shop opens, eleven successful buys, two booster actions, two boss reward events, `241` total gold earned, and `15` final gold. Recent tuned logs also included consumable purchases, so consumable access is present but should remain a closeout observation item because it appears less frequently than equipment/mastery access.
- Focused Godot MCP shop/access probe before the rebalance confirmed content counts of `25` equipment, `6` consumables, `6` mastery cards, `2` boosters, and `5` relics. It also showed the old first-shop guarantee was `equipment:coin_purse`, and boosters appeared in only `12` of `60` first-shop samples.
- Post-rebalance Godot MCP composition probe over `240` generated shops confirmed booster guarantee and softer offer weighting: `240` booster slots, `387` equipment slots, `74` mastery-card slots, and `19` consumable slots; all sampled shops had a booster, no duplicate offers appeared, and equipment remained the dominant non-booster category.
- Focused Godot MCP first-shop probe confirmed the first shop at `10` gold now includes `shortsword`, a booster, and no `coin_purse` guarantee; `Shortsword` is the intended affordable first damage item.
- Focused Godot MCP booster probe bought a `10`-gold `fire_booster` and produced three non-relic options: `fire_scroll` consumable, `ruby_brooch` equipment, and `fire_mastery` mastery card.
- Focused Godot MCP relic filter probe pre-owned `deep_pockets`, then opened a shop and confirmed the shop relic offer was a different relic (`crown_of_chains`), preserving owned-relic filtering.
- Focused Godot MCP relic persistence probe bought the level relic, reopened later same-level shops, and confirmed the same relic id stayed visible as `sold_out=true`; after level advance, the next level generated a different unsold relic offer.
- Focused Godot MCP full-slot probe confirmed booster option choice fails explicitly with `equipment_slots_full` or `consumable_slots_full` when those inventories are full, while `replace_pending_booster_option(...)` succeeds for both equipment and consumable replacement paths.
- Godot MCP `get_project_info` confirmed Godot `4.6.2`, `RunState` autoload, and `res://scenes/main.tscn` as the main scene. `view_script` passed for `shop_service.gd` and `content_registry.gd`. `git diff --check` passed. `get_godot_errors` retained two stale enum reload diagnostics from older sessions and failed ad hoc probe attempts; the final focused M10-06 probes executed successfully.
- Follow-up Run Log observability patch improved future M10-06 evidence capture without changing shop behavior. `shop_open` now exports sanitized item offer, relic offer, type-count, booster-presence, reroll, and pending-booster details; `shop_action` exports gold before/after plus selected/purchased/granted details and shop before/after snapshots; `shop_leave` keeps a final before/after shop snapshot so sold-out relic state is visible in exported logs.
- Focused Godot MCP Run Log probes confirmed first-shop exports include `shortsword`, a booster, and relic fields; booster buy actions include selected offer and shop before/after details; text reports summarize shop data; and a bought same-level relic logs as `sold_out=true`, `available=false`, and `owned=true` in the next same-level shop.

## M10-07: Focused Playtest Loop And Closeout

- Status: `done`
- Owner/scope: Confirm M10 creates a playable baseline for Milestone 11.
- Deliverable: Final M10 playtest notes and tracker updates.
- Progress: Compared tuned Run Logs against the M10-02 untuned baseline and found M10 creates a playable baseline for Milestone 11. The untuned baseline opened first shops with `3`, no shop, and `0` gold across the three counted runs, while tuned runs now show a first-shop floor of `10+` gold and practical shop access. Accepted tuned run `run_1777968781_770133_2026-05-05t16_13_01` reached Dungeon 3 and died at Vault Executioner after six fight victories. Accepted tuned run `run_1777969048_434533_2026-05-05t16_17_28` completed the full run with eight shop opens, booster actions, boss relic rewards, and longer Dungeon 3 fights. Newest checked run `run_1777973747_694854_2026-05-05t17_35_47` reached level 3 enemy 2, opened the first shop with `13` gold, offered affordable `shortsword`, booster, and consumable options, bought equipment and boosters, took two boss relic rewards, exposed level 3 equipment-slot-full friction, then died to Goldbound Keeper with `42` gold. No M10 blocker was found in early gold access, survivability, shop/content access, first-shop affordability, booster access, relic access, or full-slot friction.
- Blockers: None for Milestone 10 closeout. Merchant Compass free-first-reroll remains deferred, and full-slot friction plus final economy/combat values should be revisited after Milestone 11 meta progression changes player power and content pressure.
- Next action: Start Milestone 11 meta progression foundation; do not deepen combat/economy rebalance until post-meta evidence exists.
- Acceptance:
  - Multiple early-run logs show improved gold access, survivability, and content access versus baseline.
  - Temporary balance assumptions are recorded.
  - Remaining post-meta tuning questions are separated from M10 blockers.
  - `todo.md` Milestone 10 status/checklist is updated only after real validation.
- Validation:
  - Godot MCP final smoke: main, combat, shop, final summary, and `get_godot_errors`.
  - Manual playtest notes or exported logs for at least 2 tuned runs.
- Docs/wiki impact: Update `todo.md`, `docs/test_plan.md`, relevant wiki pages, and `wiki/log.md` if wiki changes.

Validation evidence:

- `git status --short --branch` confirmed work on `codex/milestone-10` with a clean starting status.
- Godot MCP `get_project_info` confirmed Godot `4.6.2`, `RunState` autoload, and `res://scenes/main.tscn` as the main scene.
- Focused Godot MCP scene instantiate smoke passed for `res://scenes/main.tscn`, `res://scenes/combat/combat_player.tscn`, `res://scenes/flow/shop_player.tscn`, and `res://scenes/flow/final_run_summary.tscn`.
- Godot MCP `play_scene main` launched and stopped successfully.
- Final Godot MCP `get_godot_errors` reported no session errors after the corrected scene smoke. An earlier ad hoc editor-script smoke failed from local probe typing and was corrected before counting validation.
- Run Log comparison covered the M10-02 baseline files `run_1777938769_177353_2026-05-05t07_52_49`, `run_1777940350_422781_2026-05-05t08_19_10`, and `run_1777941462_641881_2026-05-05t08_37_42`, plus tuned files `run_1777968781_770133_2026-05-05t16_13_01`, `run_1777969048_434533_2026-05-05t16_17_28`, and `run_1777973747_694854_2026-05-05t17_35_47`.
- `git diff --check` passed after documentation/wiki updates.

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
