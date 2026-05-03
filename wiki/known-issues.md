# Known Issues

**Summary**: Current risks, validation gaps, and implementation mismatches that should stay visible while the prototype evolves.

**Sources**: `docs/test_plan.md`, `docs/system_architecture.md`, `docs/architecture_review_tasks.md`, `docs/tmp_transition_delay_handoff.md`, `scripts/shop/shop_service.gd`, `scripts/content/content_registry.gd`, `scripts/core/run_state.gd`

**Last updated**: 2026-05-04

---

## Overview

The prototype is functional, but several QA items remain unchecked and a few implementation gaps still need follow-up. (source: `docs/test_plan.md`)

## Details

- General combat touch input selection still needs explicit validation on device. Shop HUD touch outside-dismissal was manually retested and confirmed during AR-04 after routing touch events through the shared HUD focus handler and refreshing selection state. (source: `docs/test_plan.md`, `scripts/flow/shop_player.gd`, `scripts/ui/player_loadout_hud.gd`)
- Board lock behavior during resolution and transitions still needs full end-to-end validation. (source: `docs/test_plan.md`)
- Desktop and mobile overlap checks for the UI remain open in the QA checklist. (source: `docs/test_plan.md`)
- Merchant Compass free-first-reroll behavior is still unchecked in the QA plan, and `scripts/shop/shop_service.gd` does not currently implement a special free reroll path. (source: `docs/test_plan.md`, `scripts/shop/shop_service.gd`)
- Full end-to-end manual playthrough of boss victory into relic choice into post-boss shop, plus final boss victory into run summary, remains useful after the 2026-05-02 overlay-route and modal layering changes, even though Godot MCP script, scene-tree, and runtime probes passed. (source: `docs/test_plan.md`, `scripts/combat/combat_player_controller.gd`, `scripts/core/run_state.gd`)
- `Start Run -> Combat` is no longer blocked by combat scene instantiation after the lazy `VisualRegistry` fix: AR-01 user route-level validation from the real Start Run button measured combat resource load around `200ms`, instantiate `0ms`, attach around `84ms`, and first usable frame around `294ms`. A 2026-05-04 follow-up generated clean derived orb PNGs in `resources/art/first_pass/derived/orbs/` so `VisualRegistry` no longer needs the expensive runtime orb-sheet cleanup on the normal path; a live Start Run trace measured resource load `232ms`, instantiate `1ms`, first usable frame at `314ms`, and `combat_after_texture_map` at `325ms`. Manual visual QA is still needed for board pop-in and perceived Start Run feel on target hardware. AR-01 also measured `Combat -> Shop` at resource load around `51ms`, instantiate `0ms`, attach around `114ms`, first usable frame around `218ms`, and `Shop -> Combat` at resource load around `2ms`, instantiate `0ms`, attach around `72ms`, first usable frame around `78ms`. (source: `scripts/ui/visual_registry.gd`, `resources/art/first_pass/derived/orbs/`, `scripts/combat/combat_player_controller.gd`, `scripts/flow/shop_player.gd`, `docs/tmp_transition_delay_handoff.md`, `docs/test_plan.md`)
- External content migration remains deferred. The current prototype source of truth is dictionary-backed `ContentRegistry` content; a future `.tres`, JSON, or other data-source migration should keep the registry read API as the compatibility boundary. (source: `docs/system_architecture.md`, `scripts/content/content_registry.gd`)
- Board-debug scene coverage was retired in AR-08. Current regression coverage should rely on `combat_player.tscn`, `shop_player.tscn`, `final_run_summary.tscn`, and focused Godot MCP editor-script probes for board resolver, combat envelope, RunState routing, and content contracts. (source: `AGENTS.md`, `docs/architecture_review_tasks.md`, `docs/test_plan.md`)
- Transition ownership contract is still not fully formalized across `RunState` and scene controllers, but AR-09 fixed confirmed high-risk gaps in Start Run failure recovery, final-summary duplicate-action guarding, and the combat wrong-step redirect trace path. Shop ready-time redirects remain an adjacent future transition-cleanup candidate rather than part of AR-09. (source: `docs/architecture_review_tasks.md`, `scripts/core/main_boot.gd`, `scripts/flow/final_run_summary.gd`, `scripts/combat/combat_player_controller.gd`, `scripts/flow/shop_player.gd`)
- Shared HUD API drift risk remains while combat and shop both evolve against `PlayerLoadoutHud`. (source: `docs/architecture_review_tasks.md`)
- Temporary diagnostics need explicit retirement criteria so they do not become accidental permanent architecture. (source: `docs/architecture_review_tasks.md`)
- AR-01 baseline capture found repeated unsourced Godot `GDScript::reload: Integer division. Decimal part will be discarded.` warnings after scene smokes. They are non-fatal in the captured session, but should be localized or cleared before architecture-touching batches rely on `get_godot_errors` as a clean regression gate. (source: `docs/test_plan.md`)
- Android CLI export on this Windows checkout can hang after writing a valid `Orbwalker.apk`, leaving `Godot_v4.6.2-stable_win64_console.exe` and Java/Gradle processes alive. The observed workaround is to verify the APK timestamp/size, run `adb install -r D:\godot\matchatro\Orbwalker.apk`, then stop the stuck console exporter and Java child. Root cause is not confirmed; candidates include Gradle shutdown, the Godot 4.6.2 console exporter, or the enabled MCP editor plugin Android export warning. (source: `wiki/setup.md`, `docs/test_plan.md`)
- Balance tuning is still open for orb spawn rates, prices, enemy stats, boss stats, and item strength. (source: `todo.md`, `docs/game_design_document.md`)

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
