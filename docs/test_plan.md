# Orbwalker Manual QA Checklist

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
- [x] Generated shop stock and booster equipment options do not show equipment already equipped by the player.
- [x] Full-slot booster rewards keep the player HUD usable and can be skipped without locking shop progression.
- [x] Normal boosters do not generate relics by default.
- [ ] Early economy usually lets a player afford at least one booster after the first enemy if they matched some gold.

Verification notes (2026-04-26):
- Shop flow is now wired to runtime systems (`ShopState`, `ShopService`) and accessible via post-fight transition to `res://scenes/flow/shop_player.tscn` (player-facing) and `res://scenes/flow/shop_placeholder.tscn` (debug/legacy).
- Milestone 6 debug shop UI supports buy, sell, reroll, relic offer purchase, booster option selection, and skip/next transitions.
- Economy actions run through `RunState` gold helpers, and combat gold gain updates are synchronized to run-level gold.
- `board_debug_controller.gd` parse stability was restored for debug add-item actions by switching `RunState` service locals to explicit `Variant`.
- User-confirmed on 2026-04-27: shop appears after boss relic reward.
- Godot MCP validation on 2026-05-02: pending booster choices no longer block the shared player HUD, full-slot picks leave the booster choices open with a visible Skip path, and equipment can be selected/sold from a contextual loadout bubble while the booster is pending.
- Godot MCP validation on 2026-05-02: editor-script service probes confirmed generated shop stock and booster equipment options exclude already-equipped equipment, consumable selling clears the selected consumable slot, `res://scenes/flow/shop_player.tscn` and `res://scenes/combat/combat_player.tscn` instantiate, and `get_godot_errors` reported no session errors.

## Milestone 7: Dungeon And Run Flow

- [x] New run initializes clean player state.
- [x] HP persists between fights.
- [x] Gold persists between fights.
- [x] Equipment, mastery, consumables, and relics persist between fights.
- [x] Each dungeon level follows Enemy 1, Shop, Enemy 2, Shop, Boss, Boss Relic Reward, Shop, Advance.
- [x] Boss type is previewed at the start of the dungeon level.
- [x] Boss relic reward is separate from shop relic offer.
- [x] Boss relic reward choices are presented in the combat victory overlay before continuing to shop.
- [x] Clearing level 3 boss can produce prototype victory.
- [x] Dying at any fight shows the combat-scene defeat overlay with run summary stats and a Main Menu button.

Verification notes (2026-04-27):
- Godot MCP editor-script sequence checks passed for:
  - clean run start (`enemy_1`, level 1, zeroed run resources),
  - full level sequence progression including boss reward and post-boss shop,
  - prototype victory summary transition after level 3 completion,
  - defeat finalization from an active run.
- Scene wiring checks passed for:
  - `res://scenes/flow/boss_relic_reward.tscn` attached to `res://scripts/flow/boss_relic_reward.gd`,
  - run summary scene/controller integration.
- Godot MCP validation on 2026-05-02: `res://scenes/combat/combat_player.tscn` opens and runs without script errors, the board-level `OutcomeSummaryPanel` is present in the running combat scene, and `RunState.run_summary_snapshot()` now reports total gold earned plus monster and boss kill counts for defeat overlays.
- Godot MCP validation on 2026-05-02: boss reward routing now keeps the player-facing flow in `res://scenes/combat/combat_player.tscn`, shows relic choices or explicit skip on the victory overlay, and then advances to `res://scenes/flow/shop_player.tscn`; `res://scenes/flow/boss_relic_reward.tscn` remains legacy/debug fallback only.
- Godot MCP validation on 2026-05-03: boss reward overlay layout now re-parents the outcome summary and scrim under `CombatLayoutRoot` at runtime, above `PlayerHudSection`, so reward buttons are no longer clipped by `BoardPanel` or buried under Elemental Mastery/player HUD. Follow-up passes keep the boss reward modal above the player HUD, widen relic cards into three readable choices, render relic images in dedicated card icon nodes above the text, keep Skip/Continue in an action row before selection, and wrap/truncate long descriptions. The player now auto-continues to shop immediately after claiming or skipping a non-final boss relic; defeating the third boss bypasses relic selection and routes directly to the victory summary. `view_script`, `get_godot_errors`, running scene-tree inspection, and `git diff --check` passed during the overlay work; the final boss routing change was script-parse/error checked but still needs an end-to-end final-boss click-through.
- Remaining unchecked persistence items require manual end-to-end fight/shop playthrough validation with real combat outcomes.
- User-confirmed on 2026-04-27: HP and gold persist correctly between fights.
- User-confirmed on 2026-04-27: equipment, consumables, mastery, and relics persist correctly between fights.

## Milestone 8: Initial Content Pack

- [x] All 6 mastery cards can appear and resolve.
- [x] All 6 consumables can appear and resolve.
- [x] All common equipment items can appear, be bought, equipped, sold, and resolve.
- [x] All uncommon equipment items can appear, be bought, equipped, sold, and resolve.
- [x] All rare equipment items can appear, be bought, equipped, sold, and resolve.
- [x] All 5 relics can appear and resolve.
- [x] At least 3 normal enemies are playable.
- [x] At least 3 bosses are playable.
- [x] Content pools respect rarity, category, orb type, and duplicate rules.
- [x] No player-facing content appears with missing text.

Verification notes (2026-04-27):
- Godot MCP script/runtime validation passed after Milestone 8 content pack updates:
  - full equipment/relic/mastery/consumable registry loads with no parse/runtime errors,
  - content validation reports `OK` in `res://scenes/combat/board_debug.tscn`,
  - shop offers now surface content descriptions from registry data.
- Godot MCP editor-script QA execution passed for Milestone 8 functional checks:
  - content totals and registry validation: 25 equipment (10 common/10 uncommon/5 rare), 6 mastery cards, 6 consumables, 5 relics, 3 enemies, and 3 bosses; validation errors `[]`,
  - mastery grant and consumable add/use/effect resolution: no failures,
  - equipment buy/equip/sell/combat-modifier resolution by rarity and relic buy/resolve flows: no failures,
  - run-sequence enemy/boss coverage: normal IDs `cavern_striker`, `cavern_defender`, `ash_hunter`, `ruin_lancer`, `vault_executioner`, `goldbound_keeper`; boss IDs `iron_gate`, `burning_knight`, `prism_warden`,
  - pool and booster rule checks: no duplicate-offer, type, level-gate, or target-orb filter violations.

## Milestone 9: UI And Game Feel

- [x] Combat HUD shows player HP, armor, gold, timer, enemy HP, enemy block, and enemy intent.
- [x] Combo count and turn result feedback are readable.
  - 2026-05-02: Combat presentation now uses a hidden `combat_speed` setting with `slow`, `normal`, `fast`, and `instant` modes, defaulting to `normal`. Drag release now holds a pre-resolve visual board until the first match flash/clear animation begins, preventing immediate refill display. Visible match feedback triggers the combo counter update, and that combo update triggers the per-match Elemental Mastery value preview. Godot MCP script/load/run checks passed. Manual feel acceptance remains visual QA.
  - 2026-05-02: Resolve presentation now uses separate visual and simulation board states. Drag-release swap overlays are cleared before resolve presentation, the resolver mutates only the simulation clone, and the visual board replays clear, gravity, and refill before committing the final board state. Godot MCP script check, deterministic replay probe, and combat scene smoke passed. Manual feel acceptance for real drag/cascade timing remains visual QA.
  - 2026-05-02: Combo timing follow-up makes combo/mastery feedback an explicit presentation phase: each pass waits for the full match flash and clear animation, then advances the single `COMBO xN` popup and matching Elemental Mastery preview sequentially for each resolver group before gravity or refill can start. Godot MCP script/error checks, resolver tick-order probe, and combat scene smoke passed. Manual feel acceptance remains visual QA.
  - 2026-05-02: Resolve presentation now prints `[ResolveTrace +NNNNms]` timing lines to the Godot console/output log. The trace records drag release, visual/simulation board setup, resolver simulation signals, presentation pass start, match flash, combo ticks, clear, gravity, refill, animation drain, and final board commit so timing issues can be compared against visible board state. Godot MCP script/error checks and combat scene smoke passed; manual trace capture during a real drag turn remains useful for feel debugging.
  - 2026-05-02: Clear, gravity, and refill presentation now start their BoardView animations before mutating the visual board clone; each visual board mutation is delayed until the matching animation duration completes and is traced as `clear_visual_commit`, `gravity_visual_commit`, or `refill_visual_commit`. Godot MCP validation passed, and user manual acceptance confirmed the revised order feels correct.
  - 2026-05-02: Mastery numeric feedback now pools during match/combo ticks. Repeated same-orb matches across cascades add into the same card value, and post-cascade turn replay releases the pooled values one card at a time while keeping beam/impact effects.
  - 2026-05-02: Same-pass match groups now present sequentially instead of all at once: groups are sorted by top row then left column, and each group flashes, clears, commits visually, and advances `COMBO xN` before the next group starts. Gravity and refill still wait until every group in the pass has cleared, preserving resolver outcome. Godot MCP script/error checks, combat scene smoke, and an editor-script ordering probe passed; manual feel acceptance remains useful for real drag timing.
  - 2026-05-02: Combo counter placement is now fixed to the center of the board stage instead of trying to dodge the matched cells. The combo readout is floating text without panel border/background, and its font/pulse size grows as combo count increases. Godot MCP script/error checks and combat scene smoke passed; manual feel acceptance remains useful.
  - 2026-05-02: Temporary mastery beam visibility was increased for playtesting by widening the replay beam and making it fully opaque.
- [x] Equipment slots are visible.
- [x] Consumable slots are visible.
- [x] Relics are visible.
- [x] Mastery levels are visible.
- [x] Item detail text is readable before purchase.
- [x] Shop controls are usable without debug tools.
- [x] Booster selection is clear.
- [x] Booster full-inventory sell-or-skip paths are clear.
- [x] Run progress and dungeon level are visible.
- [x] Important actions have clear visual or audio feedback.
  - 2026-05-02: Added `AudioManager` placeholder audio with generated looped music for menu/combat/shop and SFX hooks for menu start, combat match/combo/result/victory/defeat, and shop purchase/reroll/sell/booster success/failure. Godot MCP script load, main runtime smoke, and scene instantiate checks passed. Manual listening/volume feel review remains pending.
  - 2026-05-02: Added a MIDI-to-WAV export path using `raw/GeneralUser GS v1.471.sf2`, exported menu/combat/shop/credit/melody WAVs into `resources/audio/music/`, and updated `AudioManager` to prefer exported music assets over generated fallback loops. Godot MCP filesystem scan, WAV load probe, and script/error checks passed. Manual listening, mix, and loop-point review remains pending.
  - 2026-05-02: Normalized exported music peaks to an audible target and set music playback to `-12 dB`; scene audio helpers now defer to `AudioManager` for the shared music volume. Godot MCP script/error checks passed. Manual listening remains pending.
  - 2026-05-02: Replaced the broken Python synth WAV export with the provided local FluidSynth binary, regenerated music as signed 16-bit stereo 44.1 kHz WAVs, and verified all exported files with Python `wave` plus Godot MCP `AudioStreamWAV` loading.
  - 2026-05-02: Main menu now owns a direct `MainMenuMusicPlayer` that loads and plays `resources/audio/music/main-menu.wav` at scene startup, independent of the global `AudioManager` path. Godot MCP confirmed the node exists in the running main scene and `get_godot_errors` reported no session errors. Manual listening remains pending.
  - 2026-05-02: Main menu music now bypasses Godot's imported WAV resource path and decodes the source signed 16-bit WAV into an in-memory `AudioStreamWAV`, matching the known-audible generated SFX path. The menu retries playback if stopped. Runtime log confirmed playback on the Master bus; manual mix/loop-point review remains pending. User confirmed it is audible, then music volume was lowered to `-12 dB`. The first-input restart workaround was removed because it restarted music when Start Run was clicked.
  - 2026-05-02: Combat/shop music now uses the same source-WAV decode path in `AudioManager`: it opens the absolute project WAV before falling back to Godot's imported resource, restarts the same key if the music player has stopped, and leaves volume at `-12 dB`. Godot MCP confirmed `combat.wav` decodes as stereo 44.1 kHz PCM with 14,012,416 data bytes and loop end 3,503,104, and a direct combat scene smoke printed `AudioManager music playing: key=combat stream=AudioStreamWAV volume_db=-12.0 bus=Master`; manual listening remains the acceptance check.
  - 2026-05-02: Added a short generated `swap` SFX that fires on each valid adjacent combat orb swap during drag. Godot MCP script/error checks passed; manual listening remains the acceptance check.
- [ ] UI elements do not overlap on desktop.
- [ ] UI elements do not overlap on mobile aspect ratios.

Verification notes (2026-04-27):
- Godot MCP script/scene checks passed for updated UI scene load + instantiation:
  - `res://scenes/combat/combat_player.tscn`
  - `res://scenes/flow/shop_player.tscn`
  - `res://scenes/flow/boss_relic_reward.tscn`
  - `res://scenes/main.tscn`
- Main scene smoke test (`play_scene` on main) ran and exited without reported session errors.
- Added responsive layout safeguards:
  - Combat board/state panel now stacks vertically in compact aspect ratios and keeps state labels wrapped.
  - Shop action rows now stack vertically in compact aspect ratios to avoid button overlap.
- Godot MCP post-change checks passed:
  - `get_godot_errors` reported no parse/runtime errors after edits.
  - `play_scene` smoke on `res://scenes/combat/combat_player.tscn` completed and exited cleanly.
  - `execute_editor_script` load/instantiate check for `res://scenes/flow/shop_player.tscn` returned success.
- Remaining Milestone 9 QA: explicit overlap checks on desktop and on-device mobile aspect ratios.
- Godot MCP validation on 2026-05-02: shared `PlayerLoadoutHud` footer now includes compact owned relics for combat and shop, the shop footer renders owned relics with compact overflow support, and combat/shop scene instantiate checks plus `get_godot_errors` reported clean after the dungeon playthrough flow fixes.
- Godot MCP validation on 2026-05-02: shared HUD relics were moved between the HP panel and equipment/consumable rows, and shop consumable slots now use the same contextual sell bubble as equipment slots.
- Godot MCP validation on 2026-05-02: shop inventory details and selling now share one non-clipped popover; clicking outside inventory focus or using non-inventory shop actions clears the selected slot and hides the popover while preserving the embedded Sell action.
Verification notes (2026-04-27, graphical asset integration pass):
- Added centralized visual mapping and fallback contract:
  - `res://scripts/ui/visual_registry.gd`
  - `res://resources/visual/first_pass_asset_map.json`
- Player-facing scene paths are now:
  - combat: `res://scenes/combat/combat_player.tscn`
  - shop: `res://scenes/flow/shop_player.tscn`
- Run routing validation:
  - `RunState` scene constants now target the player-facing combat/shop scenes.
  - Main menu keeps explicit debug access to `res://scenes/combat/board_debug.tscn`.
- Godot MCP automated checks completed:
  - script parse/load checks: no errors (`get_godot_errors`)
  - scene instantiate checks passed for:
	- `res://scenes/combat/combat_player.tscn`
	- `res://scenes/flow/shop_player.tscn`
	- `res://scenes/combat/board_debug.tscn`
	- `res://scenes/main.tscn`
  - runtime smoke passed (`play_scene` + `stop_running_scene`) for:
	- `res://scenes/combat/combat_player.tscn`
	- `res://scenes/flow/shop_player.tscn`
	- `res://scenes/main.tscn`
  - visual registry load probe passed (combat/shop backgrounds, orb atlas, intent/rarity badges, enemy portrait, icon atlas, VFX atlas).
- Manual checks still required (not automated):
  - full run-flow interaction from main menu through real fights/shops with user input,
  - visual overlap audit at `1920x1080`, `1366x768`, `900x1600`, and `1080x1920`,
  - readability/polish review for long offer text and dense inventory states.
Verification notes (2026-04-29, player section reference revamp):
- Rebuilt the combat player panel to follow the provided reference bottom HUD: hero portrait card, primary HP bar, compact equipment/consumable rail, and persistent mastery strip.
- Follow-up cleanup hid the cramped armor bar, stat chip row, and turn summary text from the compact player panel to prevent visual clutter at scaled desktop sizes.
- Second spacing cleanup reduced the hero card footprint, pulled the equipment/consumable rail closer to the HP row, and compressed the mastery strip to remove excess empty space.
- Layout correction pass keeps the simplified visible data set while matching the reference HUD structure: larger left hero portrait, long primary HP bar, larger equipment/consumable slot rail, and full-width bottom mastery strip with icon-plus-number mastery cells; armor/stat rows remain hidden to avoid empty placeholder UI.
- Godot MCP load/instantiate check passed for `res://scenes/combat/combat_player.tscn` with the new player-panel nodes present.
- Godot MCP runtime scene-tree inspection confirmed the player panel, loadout rails, and mastery strip stay within the current `1080x1920` design-space player panel bounds.
- Still needs manual visual review at `1920x1080`, `1366x768`, and `900x1600` before the desktop/mobile overlap checklist items can be marked complete.
Verification notes (2026-04-29, player section cohesion fix pass):
- Added `VitalsFrame`, `ArmorBadge`, and `ArmorBadgeLabel` to the combat player `VitalsPanel` and rewired player HUD sync to show `HP current / max` text plus conditional armor badge visibility.
- Armor badge now follows Slay the Spire-inspired visibility: hidden when armor is `0`, visible with `BLOCK +N` when armor is positive.
- Rebalanced player panel design-space geometry toward a three-layer HUD composition (`hero status`, `loadout`, `mastery`) while keeping board and combat logic unchanged.
- Updated loadout empty states to recessed silhouettes for equipment and consumables instead of generic placeholders.
- Updated mastery cells to `icon + Lv N` badges instead of bare numeric counters for non-debug readability.
- Godot MCP `play_scene` + running scene-tree checks confirmed new nodes and bounds:
  - `VitalsPanel` now includes `VitalsFrame` and `ArmorBadge`.
  - `ArmorBadge` starts hidden at zero armor.
  - `MasteryIcons` renders six fixed-width cells under the expanded `MasteryStrip`.
- Manual visual acceptance pass is still required at `1080x1920`, `900x1600`, `1920x1080`, and `1366x768`.
Verification notes (2026-05-02, connected shared player HUD pass):
- Promoted `PlayerLoadoutHud` into the canonical combat/shop player HUD layout helper with `apply_player_hud_layout(...)` and `apply_player_hud_chrome(...)`; `apply_player_footer_layout(...)` remains as a compatibility wrapper for footer-only callers.
- Combat and shop now use one connected `PlayerHudSection` contract at `Rect2(Vector2(0, 1092), Vector2(1080, 828))`, with Elemental Mastery at `Rect2(Vector2(16, 0), Vector2(1048, 172))` and the footer at `Rect2(Vector2(0, 188), Vector2(1080, 640))`.
- Shared visible HUD content is hero portrait, `HP current / max`, 5 equipment slots, 3 consumable slots, and the Elemental Mastery rail. Shop-specific footer gold, relic rows, sell/reroll controls, and relic offers stay outside the shared HUD; shop gold remains in the top bar.
- Shop content was compacted above the locked HUD position without changing buy/sell/reroll/continue/booster behavior. The shop action row ends at design-space `y=1076`, leaving a 16px gap before `PlayerHudSection` starts at `y=1092`.
- Godot MCP checks completed:
  - `view_script` parse checks for `res://scripts/ui/player_loadout_hud.gd`, `res://scripts/flow/shop_player.gd`, and `res://scripts/combat/combat_player_controller.gd` reported no session errors.
  - `execute_editor_script` scene load/instantiate check passed for `res://scenes/combat/combat_player.tscn` and `res://scenes/flow/shop_player.tscn`.
  - Combat `play_scene current` plus running scene-tree inspection confirmed `PlayerHudSection`, `ElementalMasteryPanel`, `PlayerPanel`, `HeroCard`, `VitalsPanel`, `EquipmentIcons`, and `ConsumableIcons` retain the shared HUD geometry.
  - Active-run shop runtime scene-tree inspection was performed through a temporary MCP-launched probe scene that started a run, advanced to shop, loaded `res://scenes/flow/shop_player.tscn`, and was removed after validation. The running shop tree matched the same `PlayerHudSection`, mastery, footer, hero, vitals, equipment, and consumable rects, and `get_godot_errors` reported no session errors after rerunning a real scene.
Verification notes (2026-04-30, elemental mastery reference replay pass):
- Rebuilt `ElementalMasteryPanel` as a taller reference-style panel between board and player HUD; the former bottom `MasteryStrip` remains hidden in combat.
- Added six large mastery cards with generated card chrome, main-menu mastery iconography, title, `Lv N`, and transient `+N DAMAGE/HEAL/ARMOR/GOLD` text in the lower card slot.
- Added generated reference assets for mastery panel frame, card chrome, elemental beams, armor shell, and hit/heal/gold impacts under `res://resources/art/first_pass/derived/ui_chrome/` and `res://resources/art/first_pass/derived/vfx/`.
- Added post-cascade turn replay from `turn_log`: Fire, Ice, Earth, Heart, Armor, and Gold cards replay left-to-right after cascades finish; enemy block is consumed before HP damage, armor gain shows shell feedback, gold beams to the gold label, and enemy response removes armor before HP.
- Godot MCP checks completed:
  - `execute_editor_script` with `ResourceLoader.CACHE_MODE_IGNORE` parsed `combat_player_controller.gd`, `player_loadout_hud.gd`, and `visual_registry.gd` with result `0`.
  - Scene load/instantiate check confirmed `ElementalMasteryPanel` and `ElementalMasteryCards` exist and the old bottom `MasteryStrip` is hidden.
  - Visual registry probe confirmed generated panel frame `1048x188`, card texture `320x256`, shell `168x168`, and hit/heal/gold impact texture loading.
  - `play_scene` on `res://scenes/combat/combat_player.tscn` reported no runtime session errors.
  - Follow-up running scene-tree inspection confirmed board/mastery/player design-space bounds after the visual correction pass: `BoardPanel` ends y=1234, `ElementalMasteryPanel` spans y=1236..1452, and `PlayerPanel` starts y=1452.
  - Running card inspection confirmed six `160x176` mastery cards, `84x84` main-menu mastery icons, no combat-card `MasteryProgress` bar nodes, a centered `ElementalMasteryTitle`, active `ElementalMasteryPanelFrame`, and old bottom `MasteryStrip` hidden.
  - Follow-up registry probe confirmed combat mastery card icons resolve through `menu_mastery_icon(orb_id)` to `res://resources/art/first_pass/derived/icons/mastery_*.png`, and card chrome resolves to the regenerated clean `mastery_card_*.png` assets.
- Read-only PNG audit confirmed generated mastery PNGs have alpha, transparent corners, and no fully opaque background coverage.
- Remaining manual verification: perform real drag-match turns to judge post-cascade replay timing/readability and run the desktop/mobile overlap audit before marking the overlap checklist items complete.
- Godot MCP validation on 2026-05-03: boss victory reward controls now use a compact combat-level modal rect and dim scrim layered above the connected player HUD, preserving the normal victory/defeat card position while fixing the boss reward overlap seen at `1080x1920`. Non-final relic claim or skip now advances directly to the shop without a post-selection confirmation card; final boss victory routes directly to the run summary.
Verification notes (2026-04-29, equipment/mastery/relic asset polish pass):
- Reprocessed all derived icon PNGs under `res://resources/art/first_pass/derived/icons/` using `tools/asset_tools/clean_derived_icons.py` to remove checkerboard backgrounds, restore alpha transparency, and normalize icon canvas sizing.
- Added compact owned-relic row rendering with overflow handling (`+N`) via `PlayerLoadoutHud.populate_relic_row(...)`; combat now keeps relic visibility in compact layout (hidden only in low-vertical layout), and shop now displays owned relic tokens in the player footer.
- Updated boss relic reward presentation in `res://scripts/flow/boss_relic_reward.gd` to visual card-style option buttons using icon, rarity tint, and description text while keeping existing reward claim logic.
- Godot MCP verification is still pending in this thread because MCP tools were not exposed in the current session; rerun `get_godot_errors`, `play_scene`, and scene instantiate checks for:
  - `res://scenes/combat/combat_player.tscn`
  - `res://scenes/flow/shop_player.tscn`
  - `res://scenes/flow/boss_relic_reward.tscn`

Verification notes (2026-04-30, main menu runtime implementation pass):
- Historical note: this pass was later superseded by the `main menu reference-match runtime art pass` below, which removed the visible debug menu path.
- `res://scenes/main.tscn` is now wired as an authored portrait menu scene with explicit zones for background, frame chrome, logo, menu stack, element row, stats panel, footer actions, version, and debug access.
- `scripts/core/main_boot.gd` now applies fixed design-space layout coordinates against the active viewport, binds mapped background/logo assets, and renders runtime panel/button chrome with `StyleBoxFlat` (generated border/button/stats PNG chrome intentionally not used at runtime).
- Functional action coverage in this pass:
  - `Start Run` starts a run and routes through `RunState.next_scene_path()`.
  - `Debug Combat` routes to `res://scenes/combat/board_debug.tscn`.
  - `Continue`, `Collection`, `Settings`, `Quit`, `Profile`, and `Achievements` are visible disabled placeholders.
- Godot MCP checks completed in-session (2026-04-30):
  - `get_godot_errors` clean after fixing runtime-ready path issues in `scripts/core/main_boot.gd`.
  - `play_scene` on main scene succeeded with no runtime errors.
  - `get_scene_tree` confirmed presence of key nodes in runtime tree: `LogoTexture`, `StartRunButton`, `DebugCombatButton`, `ElementRow`, `StatsPanel`, `FooterActions`.
  - `simulate_input` (`ui_focus_next` + `ui_accept`) transitioned from `res://scenes/main.tscn` into `res://scenes/combat/combat_player.tscn`, confirming `Start Run` route wiring.
  - `DebugCombatButton` wiring validated via scene-signal + script-target inspection (`_on_debug_fight_button_pressed` contains `res://scenes/combat/board_debug.tscn`); direct button-press simulation still needs manual click validation.
- Visual cleanup verified:
  - Reprocessed `main_menu_logo_orbwalker_v1_alpha.png` to remove baked checkerboard background regions.
  - Runtime screenshot now shows transparent logo composition over the main-menu background.
- Main menu defect list from runtime screenshot review (2026-04-30) and fix status:
  - Logo clipping/oversize from native texture dimensions forcing control minimum size: fixed in `scripts/core/main_boot.gd` (`TextureRect.EXPAND_IGNORE_SIZE` + safe-area rect layout).
  - Logo overlapping menu stack: fixed by moving logo/menu zones to non-overlapping safe-area coordinates.
  - Element row overflow and right-edge clipping (`Fire/Ice/Earth/...` lane wider than viewport): fixed by icon minimum-size clamping and texture-expand handling.
  - Stats panel overflow and stat icon bleed beyond panel bounds: fixed by icon size clamping and stats-row bounds enforcement.
  - Footer action row vertically exploding from 384px icon minimum size: fixed by downscaled runtime footer icon textures and capped icon width.
  - Footer row colliding with bottom controls: fixed after footer height normalization.
  - Bottom text overlap (`StatusLabel` crossing version/debug controls): fixed by hiding `StatusLabel` in runtime.
  - Right-edge clipping of footer/element text: fixed after safe-area coordinate remap and bounded container widths.
- Remaining verification is still manual:
  - visual overlap/readability audit at `1080x1920`, `900x1600`, `1920x1080`, and `1366x768`,
  - direct mouse-click confirmation for `Debug Combat` routing in editor runtime.

Verification notes (2026-04-30, main menu reference-match runtime art pass):
- `res://scenes/main.tscn` now removes visible debug-menu entry points and keeps `Start Run` as the only player-facing functional action on the menu surface.
- `scripts/core/main_boot.gd` now resolves and uses generated menu art assets from `resources/visual/first_pass_asset_map.json` for:
  - outer border (`menu.outer_border`),
  - menu button chrome (`menu.button_primary`, `menu.button_secondary`),
  - stats strip chrome (`menu.stats_panel`),
  - stats/footer icon sets (`menu.menu_icons`),
  - mastery row icon reuse (`menu.reused_mastery_icons`).
- Main-menu copy and hierarchy were restaged for closer reference parity:
  - larger logo and right-biased menu stack,
  - larger element medallion row,
  - larger footer action plates,
  - stronger gold text treatment with outlines.
- Godot MCP checks completed in-session (2026-04-30):
  - `get_godot_errors`: no parse/runtime errors.
  - `play_scene` (`main`): scene launches successfully.
  - `get_scene_tree` (`running_scene`): `DebugCombatButton` is absent; `OuterBorderTexture`, `MenuButtonColumn`, `ElementRow`, `StatsPanel`, and `FooterActions` are present.
  - `StartRunButton` remains connected to `_on_start_fight_button_pressed` and still routes through `RunState.next_scene_path()`.
- Remaining manual verification:
  - visual overlap/readability audit at `1080x1920`, `900x1600`, `1920x1080`, and `1366x768`,
  - user click-through confirmation from main menu into combat at runtime.

Verification notes (2026-04-30, main menu checkerboard asset cleanup):
- Fixed the checkerboard-background regression by reprocessing opaque generated menu chrome and menu icon PNGs into real transparent assets using `tools/asset_tools/clean_menu_art.py`.
- Cleaned assets now report alpha ranges of `0-255` instead of fully opaque `255-255` for the outer border, primary/secondary button plates, stats panel, and menu icon family.
- Reduced menu button, footer button, and stats panel texture-slice margins in `scripts/core/main_boot.gd` so cleaned textures render visibly inside the current compressed runtime layout.
- Godot MCP checks completed in-session (2026-04-30):
  - `get_godot_errors`: no parse/runtime errors.
  - `play_scene` (`main`): scene launches successfully.
  - `get_running_scene_screenshot`: main menu background is visible through cleaned chrome; no opaque checkerboard slab remains over the menu.
- Remaining manual verification:
  - full visual overlap/readability audit at `1080x1920`, `900x1600`, `1920x1080`, and `1366x768`.

Verification notes (2026-04-30, character art polish pass):
- Added deterministic in-repo character placeholder PNGs for:
  - `res://resources/art/first_pass/heroes/hero_orbwalker.png`
  - `res://resources/art/first_pass/enemies/enemy_ruin_lancer.png`
  - `res://resources/art/first_pass/enemies/enemy_vault_executioner.png`
  - `res://resources/art/first_pass/enemies/enemy_goldbound_keeper.png`
- Updated portrait wiring and registry:
  - `VisualRegistry.enemy_portrait(enemy_id)` now covers all runtime `enemy_id` values from `RunState` encounter tables plus fallback `training_goblin`.
  - `VisualRegistry.hero_portrait()` added and used by both combat and shop.
  - `resources/visual/first_pass_asset_map.json` now includes complete `enemy_portraits` entries and `hero_portraits.default`.
- Godot MCP checks completed:
  - `get_godot_errors`: session reported no parse/runtime errors after script/resource updates.
  - editor-script portrait probe: hero and all runtime enemy/boss portraits loaded with no missing IDs; includes `ruin_lancer`, `vault_executioner`, `goldbound_keeper`, and boss IDs (`iron_gate`, `burning_knight`, `prism_warden`).
  - runtime combat check (`play_scene` on `res://scenes/combat/combat_player.tscn` + `get_node_properties`): first encounter is `enemy_1` and both `EnemyPortrait` and `PlayerPortrait` are visible and bound to `enemy_cavern_striker.png` and `hero_orbwalker.png`.
- Remaining manual verification:
  - interactive progression to first boss in runtime combat (to observe live swap from normal-enemy portrait to boss portrait during real run advancement),
  - interactive shop-step runtime check to confirm footer hero portrait visually matches combat portrait in the same run session.

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
