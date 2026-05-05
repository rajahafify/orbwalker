# Known Issues

**Summary**: Current risks, validation gaps, and implementation mismatches that should stay visible while the prototype evolves.

**Sources**: `docs/test_plan.md`, `docs/system_architecture.md`, `docs/architecture_review_tasks.md`, `docs/tmp_transition_delay_handoff.md`, `scripts/shop/shop_service.gd`, `scripts/content/content_registry.gd`, `scripts/core/run_state.gd`

**Last updated**: 2026-05-05

---

## Overview

The prototype is functional, but several QA items remain unchecked and a few implementation gaps still need follow-up. (source: `docs/test_plan.md`)

## Details

- General combat touch selection offset was manually retested and accepted during AR-13 for real Android touch drag, rapid-tap feel, cascade feel after drag release, and board coordinate accuracy. Broader Android/on-device QA remains useful for layout, audio, and full-run feel. Shop HUD touch outside-dismissal was manually retested and confirmed during AR-04 after routing touch events through the shared HUD focus handler and refreshing selection state. (source: `docs/test_plan.md`, `docs/architecture_review_tasks.md`, `scripts/combat/board_drag_input_handler.gd`, `scripts/flow/shop_player.gd`, `scripts/ui/player_loadout_hud.gd`)
- Board lock behavior during resolution and transitions still needs full end-to-end validation. (source: `docs/test_plan.md`)
- Desktop and mobile overlap checks for the UI remain open in the QA checklist. (source: `docs/test_plan.md`)
- Merchant Compass free-first-reroll behavior is still unchecked in the QA plan, and `scripts/shop/shop_service.gd` does not currently implement a special free reroll path. (source: `docs/test_plan.md`, `scripts/shop/shop_service.gd`)
- Boss reward and final summary route sanity was manually accepted during AR-17 for normal victory continue, boss reward claim/skip, final boss summary, defeat summary, debug fight win/lose, and main-menu return behavior. Longer full-run playthroughs remain useful for Milestone 10 balance and content QA rather than as an open AR route blocker. (source: `docs/test_plan.md`, `docs/architecture_review_tasks.md`, `scripts/combat/combat_player_controller.gd`, `scripts/core/run_state.gd`)
- `Start Run -> Combat` is no longer blocked by combat scene instantiation after the lazy `VisualRegistry` fix: AR-01 user route-level validation from the real Start Run button measured combat resource load around `200ms`, instantiate `0ms`, attach around `84ms`, and first usable frame around `294ms`. A 2026-05-04 follow-up generated clean derived orb PNGs in `resources/art/first_pass/derived/orbs/` so `VisualRegistry` no longer needs the expensive runtime orb-sheet cleanup on the normal path; a live Start Run trace measured resource load `232ms`, instantiate `1ms`, first usable frame at `314ms`, and `combat_after_texture_map` at `325ms`. Manual visual QA is still needed for board pop-in and perceived Start Run feel on target hardware. AR-01 also measured `Combat -> Shop` at resource load around `51ms`, instantiate `0ms`, attach around `114ms`, first usable frame around `218ms`, and `Shop -> Combat` at resource load around `2ms`, instantiate `0ms`, attach around `72ms`, first usable frame around `78ms`. (source: `scripts/ui/visual_registry.gd`, `resources/art/first_pass/derived/orbs/`, `scripts/combat/combat_player_controller.gd`, `scripts/flow/shop_player.gd`, `docs/tmp_transition_delay_handoff.md`, `docs/test_plan.md`)
- External content migration remains deferred. The current prototype source of truth is dictionary-backed `ContentRegistry` content; a future `.tres`, JSON, or other data-source migration should keep the registry read API as the compatibility boundary. (source: `docs/system_architecture.md`, `scripts/content/content_registry.gd`)
- Board-debug scene coverage was retired in AR-08. Current regression coverage should rely on `combat_player.tscn`, `shop_player.tscn`, `final_run_summary.tscn`, and focused Godot MCP editor-script probes for board resolver, combat envelope, RunState routing, and content contracts. (source: `AGENTS.md`, `docs/architecture_review_tasks.md`, `docs/test_plan.md`)
- Transition ownership contract is still not fully formalized across `RunState` and scene controllers, but AR-09 fixed confirmed high-risk gaps in Start Run failure recovery, final-summary duplicate-action guarding, and the combat wrong-step redirect trace path. A post-review safety cleanup also made player-shop Continue/Menu unlock their buttons and show status text if the traced scene-change call itself fails. Shop ready-time redirects remain an adjacent future transition-cleanup candidate rather than part of AR-09. (source: `docs/architecture_review_tasks.md`, `scripts/core/main_boot.gd`, `scripts/flow/final_run_summary.gd`, `scripts/combat/combat_player_controller.gd`, `scripts/flow/shop_player.gd`)
- Transition failure recovery still has two narrow follow-ups from the AR closeout review: `final_run_summary.gd` starts a fresh run before confirming the `Start New Run` scene change, so a failed transition can leave the old summary visible while `RunState` contains a new active run; `main_boot.gd` starts combat music and stops menu music before confirming the Start Run scene change, so a failed transition can leave combat music playing on the main menu. These are failure-path issues, not known normal-route blockers. (source: `scripts/flow/final_run_summary.gd`, `scripts/core/main_boot.gd`)
- `combat_player_controller.gd` is still large after the AR helper extractions: 2432 lines on the AR-18 branch. The god-object risk is reduced because debug console, turn-log formatting, layout, VFX, drag input, placeholder textures, visual chrome, resolve presentation, outcome overlay presentation, and HUD snapshot building are extracted, but combat flow routing, scene-node HUD application, and turn orchestration remain in the controller and should be treated as future coordinator-boundary refactor candidates. (source: `docs/architecture_review_tasks.md`, `scripts/combat/combat_player_controller.gd`)
- Shared HUD API drift risk remains while combat and shop both evolve against `PlayerLoadoutHud`. (source: `docs/architecture_review_tasks.md`)
- Temporary diagnostics are retained intentionally for Milestone 10 QA: `RunState` FlowTrace logs, combat `ResolveTrace` logs, and the feature-flagged AR-01 combat result-envelope probe. They should be retired, feature-flagged further, or moved into a narrower debug harness in a later cleanup task if they outlive balance/QA usefulness. (source: `docs/architecture_review_tasks.md`, `docs/test_plan.md`, `scripts/core/run_state.gd`, `scripts/combat/combat_player_controller.gd`, `scripts/debug/ar01_combat_result_probe.gd`)
- AR-01 baseline capture found repeated unsourced Godot `GDScript::reload: Integer division. Decimal part will be discarded.` warnings after scene smokes. Later AR batches repeatedly reached no-session-error `get_godot_errors` gates, but if the warning reappears it should still be localized before treating error output as a clean regression signal. (source: `docs/test_plan.md`)
- Android CLI export on this Windows checkout can hang after writing a valid `Orbwalker.apk`, leaving `Godot_v4.6.2-stable_win64_console.exe` and Java/Gradle processes alive. The observed workaround is to verify the APK timestamp/size, run `adb install -r D:\godot\matchatro\Orbwalker.apk`, then stop the stuck console exporter and Java child. Root cause is not confirmed; candidates include Gradle shutdown, the Godot 4.6.2 console exporter, or the enabled MCP editor plugin Android export warning. (source: `wiki/setup.md`, `docs/test_plan.md`)
- Balance tuning is tracked through the Milestone 10 task tracker. The M10-01 inventory confirmed the active tuning owners before value changes: shop pricing and much prototype content live in dictionary-backed `ContentRegistry`, while current runtime encounter selection and enemy/boss stats are still owned by `RunState`. `ContentRegistry` still carries older enemy rows for contract/content coverage, so active enemy HP/intent tuning should use `RunState` unless ownership is deliberately migrated later. (source: `docs/milestone_10_balance_tasks.md`, `scripts/content/content_registry.gd`, `scripts/core/run_state.gd`, `todo.md`, `docs/game_design_document.md`)
- M10-02 captured 3 human-played untuned baseline logs before tuning. The evidence shows mixed blockers: first-shop affordability can be weak, low-effectiveness play can die before shop access, and stronger runs still hit level 2-3 survivability pressure. M10-03 added prototype balance levers for starting gold, gold orb access, shop price/reroll multipliers, fight base rewards, and enemy HP/damage multipliers. M10-04 now uses fixed fight base rewards (`10/12/14` gold by dungeon level), neutral early Gold/shop/reroll multipliers, and a guaranteed exact 10-gold offer in the first level-1 shop; M10-05 should handle survivability separately. These values are temporary M10 playtest scaffolding, not final balance. (source: `docs/milestone_10_balance_tasks.md`, `docs/test_plan.md`, `scripts/core/run_state.gd`, `scripts/combat/combat_turn_logger.gd`, `scripts/shop/shop_service.gd`)
- Screenshot-reported combat victory overlay bug from 2026-05-05 was fixed for the M10-04 flow: the victory overlay now formats total fight gold as base reward plus matched gold, so a first fight with `+3` matched gold and `10` base reward displays `GOLD GAINED +13`, `Defeat enemy: 10 gold`, and `Bonus gold: 3 gold`. Manual visual QA remains useful because the focused validation covered formatter/runtime payloads rather than a screenshot pass. (source: user screenshot on 2026-05-05, `scripts/combat/combat_player_controller.gd`, `scripts/combat/combat_turn_logger.gd`, `scripts/core/run_state.gd`)

## Important Files

- `docs/test_plan.md` - current QA gaps
- `docs/architecture_review_tasks.md` - architecture-maintenance tracker
- `scripts/shop/shop_service.gd` - shop behavior and reroll logic
- `scripts/content/content_registry.gd` - current content model
- `docs/system_architecture.md` - planned content model
- `docs/tmp_transition_delay_handoff.md` - temporary transition-stall diagnostic handoff
- `export_presets.cfg` - Android APK export preset

## Open Questions

- Which of the remaining QA items should be treated as blockers versus post-prototype polish. (source: `docs/test_plan.md`)

## Related Pages

- [[architecture]]
- [[setup]]
- [[decisions]]
- [[open-questions]]
