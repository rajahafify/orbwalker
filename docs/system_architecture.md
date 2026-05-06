# Orbwalker System Architecture

Source GDD: `docs/game_design_document.md`  
Type: Long-lived technical architecture and implementation reference

## Purpose

This document converts the GDD into implementation decisions before gameplay coding begins. It is the canonical architecture reference and should remain valid beyond Milestone 0.

No folders, scenes, project settings, gameplay scripts, resource classes, or stub code are created as part of this project-management pass.

## Scope Confirmation

The first playable target is the GDD vertical slice, not the full 10-level game.

Included in the first playable:

- One generic hero.
- One dungeon.
- 3 dungeon levels.
- 5x6 orb board.
- Six orb types: Fire, Ice, Earth, Heart, Armor, Gold.
- Puzzle & Dragons style free orb movement.
- 5-second move timer.
- Same-type straight, L, and T matching.
- Cascades.
- Turn-based combat with visible enemy intent.
- Persistent player HP across the run.
- Temporary armor that expires after enemy action by default.
- Gold economy from matched gold orbs.
- Shop after each fight.
- 3 random shop item slots.
- 1 shop relic offer per dungeon level.
- Boss relic reward.
- 5 equipment slots.
- 3 consumable slots.
- 6 mastery cards.
- 6 consumables.
- 20 to 30 equipment items.
- 5 relics.
- At least 3 normal enemies.
- At least 3 bosses.
- Basic victory and defeat flow.

Deferred until after the first playable:

- Full 10 dungeon level run.
- Multiple dungeons.
- Multiple hero types.
- Ascension-style difficulty.
- Meta progression beyond content unlock planning.
- Hazard orbs, locked orbs, advanced boss rules, and future elemental identities.
- Permanent save system, unless needed for testing.
- Final art, final audio, and full production polish.

## Proposed Folder Structure

This original planning structure has been superseded by the live prototype and the scene-structure follow-up plan in `docs/scene_structure_refactor_plan.md`. The current first playable flow is finalized enough that `scenes/` should be refactored around full screens and reusable components instead of early milestone folders.

```text
res://
  scenes/
	main.tscn
	combat/
	shop/
	run/
	ui/
  scripts/
	core/
	board/
	combat/
	content/
	run/
	shop/
	ui/
	debug/
  resources/
	content/
	  equipment/
	  mastery/
	  consumables/
	  relics/
	  boosters/
	  enemies/
	  bosses/
	  pricing/
	visual/
	  orbs/
	  icons/
  docs/
```

Ownership intent:

- `scripts/core/`: shared primitives such as IDs, RNG helpers, result structs, and lightweight utility classes.
- `scripts/board/`: board state, orb movement, match detection, gravity, refill, and board view coordination.
- `scripts/combat/`: combat state machine, scoring, enemy intent resolution, and combat-specific effect timing.
- `scripts/content/`: content resource classes, registry, validation, and effect definitions.
- `scripts/run/`: run state, dungeon sequence, victory, defeat, and transition ownership.
- `scripts/shop/`: shop generation, pricing, reroll, purchase, sell, and booster opening.
- `scripts/ui/`: presentation components that read state and send commands but do not own gameplay rules.
- `scripts/debug/`: debug-only tools for seeds, board layouts, test fights, and run manipulation.

Updated scene ownership target:

- Full player-facing screens should live under a dedicated screen/app taxonomy.
- Reusable scene composition units, such as board surface and player HUD, should live under shared component folders.
- Development-only visual comparison scenes should live under a development/preview folder.
- Combat and shop should mount the same Player HUD component rather than redefining HUD internals through separate screen-local layout constants.

See `docs/scene_structure_refactor_plan.md` for the proposed final folder layout, SOLID ownership rules, and stepwise migration tasks.

## Content Data Format Decision

The live prototype currently uses dictionary-backed default content inside `ContentRegistry` as the runtime source of truth. `ContentRegistry` is the compatibility API for content reads, validation, shop pools, shop pricing, and future migration work. Callers should use registry methods such as `get_equipment()`, `list_equipment()`, `shop_item_pool()`, `shop_relic_pool()`, `shop_pricing_config()`, and `content_contract_snapshot()` instead of reading a concrete storage backend directly. (source: `scripts/content/content_registry.gd`)

Godot `Resource`-based content remains a possible later data-source migration, not the current prototype source of truth. A later migration should keep `ContentRegistry` as the read API and adapt data loading behind it so combat, progression, shop, HUD, and debug callers keep the same dictionary-shaped contracts. JSON-backed content would need the same compatibility boundary.

Deferred Resource-backed content candidates:

- `EquipmentData`
- `MasteryCardData`
- `ConsumableData`
- `RelicData`
- `BoosterPackData`
- `EnemyData`
- `BossData`
- `IntentData`
- `ShopPricingData`
- `OrbSpawnTableData`

Common fields for content resources:

- `id`
- `display_name`
- `description`
- `icon`
- `tags`
- `unlock_state`
- `sort_order`

Item-specific fields:

- Equipment: rarity, base_price, effect list, slot rules, duplicate policy.
- Mastery card: target orb type, level increase, cap.
- Consumable: target rules, board mutation effect, slot behavior.
- Relic: effect list, acquisition source, duplicate policy.
- Booster pack: generated pool, option count, rarity weighting, orb or category filter.
- Enemy: max HP, intent cycle, level scaling values.
- Boss: max HP, boss type, preview text, intent cycle, special rule data, scaling values.
- Pricing: rarity price bands, dungeon level modifier, reroll curve, sell percentage.
- Orb spawn table: weights per orb type, modifiers for relics or level rules.

Effect representation:

- Use data-defined effect descriptors for common effects.
- Use scripted effect handlers only for effects that cannot be expressed with common descriptors.
- Every effect should declare its timing hook, target, operation, value, and condition.

Examples of common effect descriptors:

- Add flat final damage if any damage orb matched.
- Add base value to one orb type.
- Add extra armor on the first armor match each turn.
- Treat combo count as higher when threshold is met.
- Increase equipment slot count.
- Modify orb spawn weights.
- Modify armor expiration behavior.

## Runtime State Ownership

State should be separated from scenes so board, combat, shop, and run logic can be tested without relying on UI nodes.

Planned runtime models:

- `RunState`
  - Owns run-level persistence: hero state, current dungeon level, current sequence step, gold, equipment, mastery levels, consumables, relics, seen or offered relics, RNG seed, and run result.

- `PlayerState`
  - Owns player stats: max HP, current HP, current armor, orb base values, equipment slots, consumable slots, move timer, equipped items, held consumables, relics, and mastery levels.

- `BoardModel`
  - Owns the 5x6 orb grid, cell helpers, board generation, current seed or RNG stream, and pure board operations.

- `CombatState`
  - Owns the active fight: current enemy, current turn, current phase, selected board, temporary turn flags, combo results, pending damage, pending healing, pending gold, and victory or defeat outcome.

- `EnemyState`
  - Owns active enemy HP, current intent index, current block for the turn, special boss state, and any temporary modifiers.

- `ShopState`
  - Owns active shop inventory: random item slots, booster offers, relic offer, reroll count, pricing snapshot, buy/sell availability, and shop exit state.

- `ContentRegistry`
  - Owns dictionary-backed default content, loaded content pools, validation results, shop pool snapshots, and shop pricing configuration. Other systems request content by ID, type, rarity, tag, category, or unlock state through registry methods, which return duplicated dictionaries for caller safety. `content_contract_snapshot()` records the current collection schema and migration boundary. (source: `scripts/content/content_registry.gd`)

Scene ownership principle:

- Scenes display state and collect player commands.
- State models own gameplay truth.
- Service or controller classes perform legal state transitions.
- UI should never directly mutate low-level board, combat, shop, or run values except through explicit commands.

## Combat Event And Effect Timing

The prototype should follow the GDD order exactly unless a future design change is documented.

Turn order:

1. Show enemy intent.
2. Wait for player drag start.
3. Start movement timer.
4. End movement on release or timer expiry.
5. Resolve all matches and cascades.
6. Build a turn result: combo count, matched orb counts, cascade data, and match groups.
7. Apply player effects in this order:
   - Heart healing.
   - Armor gain.
   - Elemental damage.
   - Gold gain.
8. Check enemy death.
9. If enemy is dead, skip remaining enemy intent.
10. If enemy survives, resolve enemy intent.
11. Expire temporary armor according to current armor duration rules.
12. Advance enemy intent.
13. Begin next turn or end fight.

Recommended effect hooks:

- `on_run_start`
- `on_dungeon_level_start`
- `on_fight_start`
- `on_turn_start`
- `before_board_input`
- `after_board_input`
- `before_match_resolution`
- `after_match_resolution`
- `before_healing`
- `after_healing`
- `before_armor_gain`
- `after_armor_gain`
- `before_damage_calculation`
- `after_damage_calculation`
- `before_enemy_damage_received`
- `after_enemy_damage_received`
- `on_enemy_defeated`
- `on_player_defeated`
- `on_turn_cleanup`
- `on_shop_enter`
- `on_shop_reroll`
- `on_item_bought`
- `on_item_sold`
- `on_consumable_used`
- `on_booster_opened`
- `on_boss_reward`

Milestone boundary note:

- Milestone 5 hook coverage is intentionally scoped to player-state actions (equipment, mastery, consumables, relics).
- Full cross-system timing coverage continues in later milestones.

Timing rules:

- Enemy block applies against player damage during the current turn only.
- Enemy attacks are skipped if the enemy dies before intent resolution.
- Heart, Armor, and Gold do not use combo scaling by default.
- Fire, Ice, and Earth use combo scaling by default.
- Armor expires after enemy action unless relics or equipment change the rule.
- Relic and equipment effects should declare whether they are passive, triggered, or replacement effects.

## Key Architecture Decisions

- Board logic should be deterministic and runnable without visual nodes.
- Match resolution should return structured results rather than directly applying combat effects.
- Combat should consume match results and produce structured combat logs.
- Shop generation should use seeded RNG and content pools.
- Content should be loaded through a registry and validated before run start.
- Content callers should depend on `ContentRegistry` read APIs, not on whether content is backed by dictionaries, Resources, JSON, or another later data source.
- Balance values should live in data where practical.
- Debug tools should be available early, but isolated from player-facing flow.

## Open Decisions Left For Later Milestones

- Exact gold orb spawn rate.
- Exact price bands by rarity and dungeon level.
- Reroll cost curve.
- Final 3-boss roster for the prototype.
- Whether L and T matches should ever grant bonus effects beyond matched orb count.
- Whether the 5-second timer should change after mobile testing.

## Architecture Baseline Completion Criteria

The architecture baseline is complete when:

- Prototype scope is confirmed against the GDD.
- Proposed folder structure is documented.
- Content data format is selected.
- Runtime state ownership is documented.
- Combat timing and effect hooks are documented.
- Manual QA checklist exists.
- Setup tasks are clearly separated from architecture documentation.
