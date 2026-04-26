# Matchatro Manual QA Checklist

Source GDD: `docs/game_design_document.md`  
Purpose: Repeatable manual checks for the first playable prototype.

This checklist is intentionally written before implementation. Items become executable as their milestones are completed.

## Milestone 0: Baseline And Scope

- [x] Confirm the current target is a 3-level first playable prototype, not the full 10-level run.
- [x] Confirm one hero and one dungeon are in scope.
- [x] Confirm all first playable systems from the GDD are represented in the roadmap.
- [x] Confirm coding/setup tasks are separate from project-management tasks.
- [x] Confirm architecture decisions are documented before gameplay scripts are written.

## Milestone 1: Board Foundation

- [x] New boards are always 5 columns x 6 rows.
- [x] All six orb types can appear: Fire, Ice, Earth, Heart, Armor, Gold.
- [x] Gold appears less often than standard orb types.
- [x] New starting boards do not contain automatic matches.
- [x] Board generation can be reproduced with a fixed seed.
- [x] Board rendering matches the underlying board state.
- [x] Board cells do not overlap or stretch incorrectly on desktop.
- [x] Board cells remain readable on mobile aspect ratios.

## Milestone 2: Free Orb Movement And Timer

- [x] Mouse input can select an orb.
- [ ] Touch input can select an orb.
- [x] Dragging starts the movement timer.
- [x] Releasing input ends the move.
- [x] Timer expiry ends the move automatically.
- [x] Movement is limited to horizontal and vertical adjacent cells.
- [x] Diagonal movement does not swap cells.
- [x] Dragging through cells displaces orbs correctly.
- [x] The selected orb and remaining timer are visually clear.
- [ ] The board is locked during resolution and transitions.

Verification notes (2026-04-26):
- Mouse drag path, displacement, and timer flow were verified in `res://scenes/combat/board_debug.tscn`.
- Touch input still needs on-device validation.
- Input lock is verified for local resolve phase; cross-system transition locks remain pending until combat/shop/run transitions are integrated.

## Milestone 3: Matching And Cascades

- [x] Horizontal matches of 3 or more are detected.
- [x] Vertical matches of 3 or more are detected.
- [x] L-shaped matches are detected.
- [x] T-shaped matches are detected.
- [x] Diagonal-only connections do not count.
- [x] Separate connected match groups count as separate combos.
- [x] Matched orbs clear once and only once.
- [x] Gravity pulls remaining orbs downward.
- [x] Refill creates new orbs from the top.
- [x] Cascades continue until no matches remain.
- [x] Cascade combos are counted in the final combo total.

Verification notes (2026-04-26):
- User-tested in `res://scenes/combat/board_debug.tscn` and confirmed Milestone 3 behavior is working as intended.
- Includes match detection (line/L/T), glow preview during drag timer window, swap/fall/refill visuals, and cascade resolution to stable board state.

## Milestone 4: Core Combat

- [x] Enemy intent is visible before player movement.
- [x] Heart matches heal the player.
- [x] Healing does not exceed max HP by default.
- [x] Armor matches add temporary armor.
- [x] Armor blocks enemy damage before HP.
- [x] Temporary armor expires after enemy action by default.
- [x] Fire damage uses combo scaling.
- [x] Ice damage uses combo scaling.
- [x] Earth damage uses combo scaling.
- [x] Heart, Armor, and Gold do not use combo scaling by default.
- [x] Gold matches add persistent run gold.
- [x] Enemy block reduces player damage for the current turn.
- [x] Enemy block does not persist by default.
- [x] Killing an enemy skips its remaining intent.
- [x] Player death ends the run cleanly.
- [x] Enemy death transitions to the correct post-fight step.

Verification notes (2026-04-26):
- Validated through `res://scenes/combat/board_debug.tscn` with Milestone 4 HUD and combat log enabled.
- Godot MCP script checks confirmed enemy block reduction math, lethal-skip intent behavior, armor block-before-HP with post-action expiration, and healing clamp behavior.
- Victory flow now requires manual `Next` button confirmation before transition to post-battle scene.

## Milestone 5: Player State Management

Phase A: Player state contracts
- [x] Player progression state contains 5 equipment slots, 3 consumable slots, relic list, and 6 mastery tracks.
- [x] Player progression state defaults are deterministic and persist through run transitions.

Phase B: State transitions
- [x] Equipment lifecycle works end to end (`equip_item`, `unequip_item`, `sell_equipment`) and updates state consistently.
- [x] Duplicate equipment and slot-limit violations are rejected with explicit error reasons.
- [x] Mastery gain updates the correct track and respects cap behavior.
- [x] Consumables can be added and used only in valid windows, then consumed and removed from slots.
- [x] Relics are added once and persist across fights for the full run.

Phase C: Effect scope for player-state actions
- [x] Equipment and relic effects apply only while active and are removed cleanly when no longer active.
- [x] Player-state actions do not require combat-specific hardcoded effect branches.

Phase D: Validation and debug visibility
- [x] Duplicate IDs, missing display data, and invalid effect references are surfaced before run entry.
- [x] Validation output reports an actionable error list with `item_id` and `reason`.
- [x] Runtime player-state snapshot is visible in debug/playtest tooling.

## Milestone 6: Shop And Boosters

- [x] Shop appears after each normal fight.
- [x] Shop appears after boss relic reward.
- [x] Shop has 3 random item slots.
- [x] Shop has 1 relic offer for the dungeon level.
- [x] Buying an item subtracts the correct gold.
- [x] Items cannot be bought without enough gold.
- [x] Equipment can be sold for full gold value.
- [x] Selling equipment removes its passive effect.
- [x] Reroll replaces the correct shop offers.
- [x] Reroll cost updates correctly.
- [ ] First shop reroll is free when Merchant Compass is active.
- [x] Booster purchase opens 3 generated options.
- [x] Choosing a booster option grants exactly one item.
- [x] Normal boosters do not generate relics by default.
- [ ] Early economy usually lets a player afford at least one booster after the first enemy if they matched some gold.

Verification notes (2026-04-26):
- Shop flow is now wired to runtime systems (`ShopState`, `ShopService`) and accessible via post-fight transition to `res://scenes/flow/shop_placeholder.tscn`.
- Milestone 6 debug shop UI supports buy, sell, reroll, relic offer purchase, booster option selection, and skip/next transitions.
- Economy actions run through `RunState` gold helpers, and combat gold gain updates are synchronized to run-level gold.
- `board_debug_controller.gd` parse stability was restored for debug add-item actions by switching `RunState` service locals to explicit `Variant`.
- User-confirmed on 2026-04-27: shop appears after boss relic reward.

## Milestone 7: Dungeon And Run Flow

- [x] New run initializes clean player state.
- [x] HP persists between fights.
- [x] Gold persists between fights.
- [x] Equipment, mastery, consumables, and relics persist between fights.
- [x] Each dungeon level follows Enemy 1, Shop, Enemy 2, Shop, Boss, Boss Relic Reward, Shop, Advance.
- [x] Boss type is previewed at the start of the dungeon level.
- [x] Boss relic reward is separate from shop relic offer.
- [x] Clearing level 3 boss can produce prototype victory.
- [x] Dying at any fight produces a run summary.

Verification notes (2026-04-27):
- Godot MCP editor-script sequence checks passed for:
  - clean run start (`enemy_1`, level 1, zeroed run resources),
  - full level sequence progression including boss reward and post-boss shop,
  - prototype victory summary transition after level 3 completion,
  - defeat summary transition from an active run.
- Scene wiring checks passed for:
  - `res://scenes/flow/boss_relic_reward.tscn` attached to `res://scripts/flow/boss_relic_reward.gd`,
  - run summary scene/controller integration.
- Remaining unchecked persistence items require manual end-to-end fight/shop playthrough validation with real combat outcomes.
- User-confirmed on 2026-04-27: HP and gold persist correctly between fights.
- User-confirmed on 2026-04-27: equipment, consumables, mastery, and relics persist correctly between fights.

## Milestone 8: Initial Content Pack

- [ ] All 6 mastery cards can appear and resolve.
- [ ] All 6 consumables can appear and resolve.
- [ ] All common equipment items can appear, be bought, equipped, sold, and resolve.
- [ ] All uncommon equipment items can appear, be bought, equipped, sold, and resolve.
- [ ] All rare equipment items can appear, be bought, equipped, sold, and resolve.
- [ ] All 5 relics can appear and resolve.
- [ ] At least 3 normal enemies are playable.
- [ ] At least 3 bosses are playable.
- [ ] Content pools respect rarity, category, orb type, and duplicate rules.
- [ ] No player-facing content appears with missing text.

## Milestone 9: UI And Game Feel

- [ ] Combat HUD shows player HP, armor, gold, timer, enemy HP, enemy block, and enemy intent.
- [ ] Combo count and turn result feedback are readable.
- [ ] Equipment slots are visible.
- [ ] Consumable slots are visible.
- [ ] Relics are visible.
- [ ] Mastery levels are visible.
- [ ] Item detail text is readable before purchase.
- [ ] Shop controls are usable without debug tools.
- [ ] Booster selection is clear.
- [ ] Run progress and dungeon level are visible.
- [ ] Important actions have clear visual or audio feedback.
- [ ] UI elements do not overlap on desktop.
- [ ] UI elements do not overlap on mobile aspect ratios.

## Milestone 10: Balance And Regression

- [ ] Level 1 normal enemies are killable in roughly 3 turns by expert play.
- [ ] Mistakes are punished without feeling immediately fatal.
- [ ] Bosses feel like distinct checks.
- [ ] Gold income supports meaningful shop decisions.
- [ ] Shop prices create tradeoffs between equipment, mastery, consumables, boosters, relics, and rerolls.
- [ ] No single common equipment item trivializes the run.
- [ ] Relics feel stronger and broader than equipment.
- [ ] At least 10 full prototype runs are recorded with notes.
- [ ] Major balance issues are logged with reproduction notes.

## Milestone 11: First Playable Build

- [ ] Exported build launches.
- [ ] A new run can be started without debug tools.
- [ ] A full 3-level run can be won.
- [ ] A full 3-level run can be lost.
- [ ] Shop, combat, boss reward, victory, and defeat paths are reachable.
- [ ] Player-facing prototype notes are available.
- [ ] Developer handoff notes are available.
- [ ] Known limitations are documented.

## General Regression Checklist

- [ ] No runtime errors appear during a normal run.
- [ ] No invalid content warnings appear in accepted content.
- [ ] Seeded runs can reproduce board, shop, and booster behavior.
- [ ] Combat logs match visible outcomes.
- [ ] Player state after transitions matches expected values.
- [ ] Leaving and entering shop does not duplicate offers or items.
- [ ] Victory and defeat cannot both trigger from the same fight.
- [ ] Debug tools do not appear in player-facing builds unless explicitly enabled.
