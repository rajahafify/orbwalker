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
- 2026-05-03 Android regression follow-up: user-reported combat touch selection was offset only on Android after tall portrait board scaling (`2,4` selected `0,0`, `3,4` selected `1,0`). The combat `BoardView.gui_input` touch path now uses local `event.position` directly, matching the working mouse path, instead of applying a second screen-to-board transform. Godot MCP script checks and desktop scene smokes passed; Android on-device touch retest remains required.
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
- Godot MCP validation on 2026-05-03: combat consumable rails now render filled consumable slots as selectable HUD buttons wired to the existing slot-indexed consumable use path, and shop relic offers now reject owned relics when generating or reusing a cached per-level relic offer. `view_script`, focused helper probes, and `get_godot_errors` reported no session errors; direct autoload editor-script probes returned `<null>` in this MCP session, so manual active-run click-through remains useful for final acceptance.
- Godot MCP validation on 2026-05-03: `PlayerLoadoutHud` now owns the shared combat/shop HUD renderer and item popover API. Combat and shop bind HUD node references, pass player/progression data through `update_player_data(...)`, delegate outside-click focus handling, and respond to the HUD's `sell_slot_requested` signal instead of creating their own item detail bubbles. The shared HUD popover covers equipment, consumables, and relics; equipment/consumables can be sold from it in combat or shop. `view_script`, scene instantiate probes, `get_godot_errors`, and `git diff --check` reported no errors; active-run visual click-through remains useful.

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
- [x] Dying at any fight shows a combat-scene defeat overlay with a Run Summary action, then routes to the final run summary page in defeat mode.

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
- Godot MCP validation on 2026-05-03: `res://scenes/flow/run_summary_placeholder.tscn` now runs as a full-screen victory/defeat summary page with menu-art background, dim scrim, wide gold-framed panel, six stat cards, readable equipment/relic sections, and large action buttons. `view_script`, scene instantiate, `play_scene current`, and running scene-tree inspection passed; `get_godot_errors` reported no session runtime errors but retained a stale open-script diagnostic for the already-fixed `TextureRect` stretch enum.
- Godot MCP validation on 2026-05-03: the combat and board-debug consoles now support `/skip <level> <fight>`, where fight `1` and `2` jump to normal fights and fight `3` jumps to that level's boss. `view_script`, `get_godot_errors`, `play_scene current` for `res://scenes/combat/board_debug.tscn`, and running scene-tree inspection passed; editor-script access to the running debug node was unavailable, so direct console-entry click-through remains a manual check.
- Transition diagnostic on 2026-05-03: temporary FlowTrace markers now split traced run-flow scene transitions into resource load, packed-scene instantiation, scene attach, destination `_enter_tree()`, `_ready()`, and first usable frame. User runtime logs for `Start Run -> Combat` originally showed `res://scenes/combat/combat_player.tscn` resource load at about `213ms`, `PackedScene.instantiate()` at about `2471ms`, scene attach at about `81ms`, and music/scene startup after attach under `100ms`. Follow-up Godot MCP probes isolated the instantiate stall to eager `VisualRegistry` construction, especially runtime per-pixel orb-sheet cleanup duplicated through `PlayerLoadoutHud`. `VisualRegistry` and `PlayerLoadoutHud` now construct cheaply, the HUD reuses the combat registry, and combat defers orb texture-map cleanup until after the first usable frame. Godot MCP validation after the fix measured `VisualRegistry.new()` around `0.013ms`, `PlayerLoadoutHud.new()` around `0.008ms`, `combat_player.tscn` instantiate around `67ms`, and direct combat-scene first usable frame around `149ms`. User route-level validation from the real Start Run button then measured combat resource load around `206ms`, instantiate around `1ms`, attach around `83ms`, first usable frame around `300ms`, and deferred orb texture-map completion around `1438ms`; the sampled Combat -> Shop route measured shop resource load around `52ms`, instantiate around `0ms`, attach around `140ms`, and first usable frame around `245ms`. A 2026-05-04 follow-up generated clean derived orb PNGs and made `VisualRegistry` load them before falling back to runtime orb-sheet cleanup; focused warm-cache probes measured `orb_texture()` around `12ms`, and a live Start Run trace measured resource load `232ms`, instantiate `1ms`, `combat_first_usable_frame` at `314ms`, and `combat_after_texture_map` at `325ms`.
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
  - 2026-05-04: CFR-02 implementation added transient floating result labels during combat turn replay for elemental enemy damage, enemy block, healing, armor gain, gold gain, enemy attack block, and player HP damage. Labels are spawned from existing `turn_log` payload fields through `CombatVfxManager` on the existing `VfxLayer`; combat math, match resolver behavior, RunState routing, combat speed modes, and early HUD refresh timing were not intentionally changed. `git diff --check` passed. Godot MCP rerun reached Godot 4.6.2, opened the edited combat scripts, instantiated `res://scenes/combat/combat_player.tscn` with `VfxLayer`, spawned all eight result-label kinds through a focused helper probe, and launched `play_scene current`. The first runtime smoke found enum reload diagnostics in the new label helper; casts were added and focused probes passed afterward. User manual QA passed the full CFR-02 visual matrix: elemental damage, Heart healing, Armor gain, Gold gain, enemy block, enemy attack block, player HP damage, label cleanup/no permanent overlap, and `combat_speed` normal/instant behavior. The final `get_godot_errors` read still retained the earlier enum diagnostics, so rerun after editor restart if they reappear.
  - 2026-05-04: CFR-03 implementation stages visible HUD values during combat turn replay so result labels/VFX appear before enemy HP/block, player HP/armor, or gold visually changes. The controller captures pre-turn display values before combat resolution, applies presentation-only staged values after each matching replay timing point, then clears staging and performs the final HUD refresh. Enemy HP/block steps after each Fire/Ice/Earth result label, and both enemy block and player armor block labels use `-N Damage Blocked`. Combat math, match resolver behavior, RunState routing, board resolve order, and `combat_speed` modes are intentionally unchanged. `git diff --check` passed. Godot MCP reached Godot 4.6.2, loaded the edited scripts, instantiated `res://scenes/combat/combat_player.tscn` with `VfxLayer`, and launched `play_scene current`. The final `get_godot_errors` read still reports the two known enum reload diagnostics from the earlier CFR-02 helper version; the new staged-HUD warning cleared after the scene smoke. User manual timing/readability QA passed on 2026-05-04.
  - 2026-05-04: CFR-04 implementation makes Elemental Mastery cards read as active contribution sources with fixed-size activation glow/frame layers, value-scaled intensity, brief activation pulses, and a card-origin pulse when mastery beams fire. Pooled `+N DAMAGE/HEAL/ARMOR/GOLD` values still stay presentation-side and release through the existing replay timing; combat math, resolver behavior, RunState routing, turn-log serialization, board order, result labels, enemy HP/block stepping, and `combat_speed` modes were not intentionally changed. Screenshot QA follow-up strengthened the source pulse and preserved active pooled feedback totals through HUD rebuilds so staged HUD updates do not clear all active cards at once. Mastery Effect SFX now plays once at each replay impact/result moment for damage, heal, armor, and gold, reusing existing placeholder SFX and leaving source launch visual-only. `git diff --check` passed. Godot MCP reached Godot 4.6.2, loaded `player_loadout_hud.gd`, `combat_vfx_manager.gd`, `combat_player_controller.gd`, and `audio_manager.gd`, reloaded edited/related scripts with `reload=0`, confirmed the combat scene has `ElementalMasteryCards`, `VfxLayer`, enemy/player portraits, and board surface, probed Fire/Heart/Armor/Gold low/high/reset activation states, confirmed active cards survive rebuild and release one at a time, confirmed source pulse plus beam spawning, confirmed `hit`/`heal`/`armor`/`gold` SFX streams resolve, confirmed mastery SFX is no longer in post-replay batching, and launched `play_scene current`. User visual/listening QA passed on 2026-05-04. The final `get_godot_errors` read still reports the two known stale CFR-02 enum reload diagnostics; the first CFR-04 ternary warning cleared after the helper fix and reload.
  - 2026-05-04: CFR-05 implementation adds presentation-only replay VFX tier hooks for Fire, Ice, Earth, Heart, Armor, and Gold. `CombatVfxManager` owns temporary per-kind thresholds and four positive tiers, scaling existing/fallback impact size, lifetime, alpha, brightness, positive result-label font size, label outline, and label container size by tier; `CombatPlayerController` only passes existing `turn_log` replay values into the VFX and positive-label helpers. Combat math, match resolver behavior, RunState routing, board order, result label text, SFX timing, staged HUD stepping, mastery feedback release, and `combat_speed` modes were not intentionally changed. After visual feedback, tier scales were increased to `1.0`, `1.5`, `2.0`, `3.0`, early-run thresholds were lowered, and positive result labels were wired to scale by tier. `git diff --check` passed. Godot MCP reached Godot 4.6.2, loaded the edited scripts, confirmed four-tier boundaries with a focused helper probe, instantiated `res://scenes/combat/combat_player.tscn` with `VfxLayer`, `ElementalMasteryCards`, enemy/player portraits, and board surface, spawned tiered replay impacts for all six kinds, confirmed lowered thresholds, confirmed tiered positive label font sizing, and launched `play_scene current`. User visual QA passed on 2026-05-04. The first helper probe hit a stale cached script before a `ResourceLoader.CACHE_MODE_IGNORE` rerun passed; final `get_godot_errors` still reports the two known stale CFR-02 enum reload diagnostics.
  - 2026-05-04: CFR-06 implementation adds presentation-only enemy-turn feedback on top of the existing enemy attack result labels. Enemy attacks now cue from the enemy portrait, travel toward the player, show an armor/block impact for `blocked_by_armor`, show a hit impact for `hp_damage`, and sequence partial blocks as block feedback plus armor HUD step before the HP hit and final HP/armor sync. The controller still reads only `turn_log.enemy_attack_resolution`; combat math, resolver behavior, RunState routing, board resolve order, player-effect replay staging, `combat_speed` modes, blocked label text, and enemy attack SFX ownership were not intentionally changed. `git diff --check` passed. Godot MCP reached Godot 4.6.2, loaded `combat_player_controller.gd` and `combat_vfx_manager.gd`, instantiated `res://scenes/combat/combat_player.tscn` with the expected VFX/enemy/player/HUD nodes, spawned the new cue/travel/block/hit VFX and block/HP labels on a temporary `VfxLayer`, confirmed combat-state payloads for fully blocked, partially blocked, and unblocked attacks, and launched `play_scene current`. User visual QA passed on 2026-05-04 for fully blocked, partially blocked, and unblocked enemy attacks. The final `get_godot_errors` read still reports the two known stale CFR-02 enum reload diagnostics.
  - 2026-05-04: CFR-07 aggregate readability QA passed for the CFR-02 through CFR-06 feedback surface. Godot MCP reached Godot 4.6.2, loaded `combat_player_controller.gd` and `combat_vfx_manager.gd`, instantiated `res://scenes/combat/combat_player.tscn` with `VfxLayer`, `ElementalMasteryCards`, enemy/player portraits, enemy HP bar, player HP/armor labels, and board surface, spawned Fire/Ice/Earth/Heart/Armor/Gold/block/player-damage result labels on a temporary `VfxLayer`, spawned generic enemy attack cue/travel/block/hit VFX, confirmed `combat_speed` timing for normal and instant through `CombatResolvePresenter`, confirmed a deterministic multi-group cascade resolver payload, and launched `play_scene current`. User manual visual QA passed on 2026-05-04 for elemental damage, Heart heal, Armor gain, Gold gain, enemy fully blocked attack, enemy HP damage, multi-group cascades, and normal/instant speed readability. The final `get_godot_errors` read still reports the two known stale CFR-02 enum reload diagnostics and no new runtime errors from the fresh scene smoke.
  - 2026-05-03: Combat startup no longer focuses the hidden debug console `LineEdit`, preventing Android from opening the soft keyboard when entering combat. Godot MCP `view_script`, `play_scene current` for `res://scenes/combat/combat_player.tscn`, running scene-tree inspection, and `get_godot_errors` passed; a rebuilt APK installed successfully with `adb install -r`. Manual on-device launch confirmation remains useful.
  - 2026-05-03: Combat layout now consumes tall Android portrait height instead of centering a fixed 1080x1920 root. The default 1080x1920 board remains 480x576, while a 1080x2400 layout probe computes an 880x1056 board and extends the shared player HUD to the bottom of the design root. Godot MCP `view_script`, `get_godot_errors`, formula probes for 1080x1920/1080x2400/900x1600, `play_scene current`, and running scene-tree inspection passed; on-device visual acceptance remains pending.
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
- 2026-05-03: Android/export audio loading now prefers imported `res://` audio streams in template builds before direct PCM source-WAV decoding, avoiding packaged-build dependence on absolute source file paths. Godot MCP confirmed imported combat/menu WAV streams load as `AudioStreamWAV`, generated `swap` SFX still builds, combat music logs from `AudioManager`, and main menu music logs from `MainMenuMusicPlayer`; Android on-device listening remains pending.
- 2026-05-03 Android regression follow-up: user reported the Android music was audible but using the old generated synth fallback instead of the uploaded WAV music. Android/template builds now route menu music through `AudioManager`, try uploaded WAV/imported music first for menu/combat/shop, configure imported `AudioStreamWAV` loop bounds, and use generated music only as fallback if WAV loading fails. Godot MCP `view_script`, `get_godot_errors`, main scene smoke, and combat scene smoke passed with audio diagnostics logging source, Android/template flags, stream class, playing state, volume, and bus. Android on-device listening retest remains required.
- 2026-05-03 Android loop follow-up: user confirmed uploaded WAV music is audible on Android but loops too early. Android/template music loading now tries direct PCM decode from the exported `res://resources/audio/music/*.wav` source first, and imported WAV fallback computes loop end from the source WAV header instead of imported sample payload size. Godot MCP script/error checks passed; Android on-device loop timing retest remains required.
- 2026-05-03 Android loop follow-up 2: because Android music still cut off, Android/template music playback now disables internal `AudioStreamWAV` looping and restarts the current music key only from the `AudioStreamPlayer.finished` signal, avoiding bad platform loop-point behavior. Diagnostics now log source, Android/template flags, manual restart state, loop mode/end, source frame count, stream data bytes, playing state, volume, and bus. Godot MCP script/error checks passed; Android on-device loop timing retest remains required.
- 2026-05-03 Android loop follow-up 3: because exported APK still returned shortened imported payload bytes, Android/template music loading now tries non-imported raw WAV byte copies under `res://resources/audio/raw_music/{menu,combat,shop}.wav.bin` before imported fallback. `AudioManager` diagnostics now label `source=raw_pcm_wav` when this path is used and report full source frame/data counts from the raw WAV header. Godot MCP parse/error checks passed; Android on-device loop-length retest remains required.
- 2026-05-03 Android loop follow-up 4: Android export preset now includes `resources/audio/raw_music/*.wav.bin` explicitly so non-imported raw WAV payloads are packaged in the APK for runtime PCM decoding. Android log verification should show `source=raw_pcm_wav` before this retest is accepted.
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
- Godot MCP validation on 2026-05-03: `PlayerLoadoutHud` was promoted from shared layout helper to the shared player-HUD owner. It exposes `bind_player_hud(...)`, `load_player_data(...)`, `update_player_data(...)`, `update_player_hud_layout()`, `handle_global_click(...)`, and `sell_slot_requested`, so combat and shop only provide data/events and scene-specific sale effects. `view_script` checks for `res://scripts/ui/player_loadout_hud.gd`, `res://scripts/combat/combat_player_controller.gd`, and `res://scripts/flow/shop_player.gd` were clean; editor-script instantiate checks passed for combat and shop scenes.
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
- 2026-05-03 update: combat can now override the connected `PlayerHudSection` rect at runtime for tall portrait layouts. Shop keeps the default shared HUD rect.
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

Verification notes (2026-05-03):
- Android export now requests portrait orientation through `display/window/handheld/orientation=1` in `project.godot`.
- A debug Android APK was exported to `Orbwalker.apk` and installed on connected device `b21e3ea8` with `adb install -r`; install returned `Success`.
- Export still reports a warning that `res://addons/gdai-mcp-plugin-godot/gdai_mcp_plugin.gdextension` has no Android `arm64` library. The APK was created anyway, but the editor MCP plugin should remain under review for Android export hygiene.
- APK/AAB-style package outputs are ignored by `.gitignore` as generated build artifacts.
- 2026-05-03 follow-up: after Android board-scaling and audio-loading fixes, a debug Android APK exported again to `Orbwalker.apk` and installed on connected device `b21e3ea8`; `adb install -r` returned `Success` and the package is present as `com.example.orbwalker`. The same MCP plugin Android `arm64` warning remains. On-device visual and listening checks are still required.
- 2026-05-03 follow-up: Android launcher icon fields now use `res://raw/icon.png` for `launcher_icons/main_192x192` and `launcher_icons/adaptive_foreground_432x432` in `export_presets.cfg`. A debug Android APK exported and installed successfully on connected device `b21e3ea8`; the same MCP plugin Android `arm64` warning remains.
- 2026-05-03 Android regression follow-up: after touch-coordinate and Android WAV-first music fixes, debug APK export to `Orbwalker.apk` succeeded with the same MCP plugin Android `arm64` warning. `adb install -r` could not run during that pass because no device/emulator was connected (`adb devices` returned an empty list), so on-device touch and listening retest remained pending.
- 2026-05-03 AR-04 Android install follow-up: Godot CLI export with `Godot_v4.6.2-stable_win64_console.exe --export-debug Android` wrote an updated `Orbwalker.apk` but hung instead of exiting, leaving a console Godot process plus Java/Gradle child. The APK timestamp/size updated and `adb install -r D:\godot\matchatro\Orbwalker.apk` returned `Success` on device `b21e3ea8`; package `com.example.orbwalker` was present. Workaround documented in `wiki/setup.md` and `wiki/known-issues.md`; root cause remains unverified.

## General Regression Checklist

- [ ] No runtime errors appear during a normal run.
- [ ] No invalid content warnings appear in accepted content.
- [ ] Seeded runs can reproduce board, shop, and booster behavior.
- [ ] Combat logs match visible outcomes.
- [ ] Player state after transitions matches expected values.
- [ ] Leaving and entering shop does not duplicate offers or items.
- [ ] Victory and defeat cannot both trigger from the same fight.
- [ ] Debug tools do not appear in player-facing builds unless explicitly enabled.

## Regression Harness / Architecture Refactor QA

- [ ] Baseline route timings are captured for `Start Run -> Combat`, `Combat -> Shop`, and `Shop -> Combat` before architecture refactor work.
- [ ] Post-change route timings are captured for the same three routes and compared against baseline.
- [ ] `PackedScene.instantiate()` no longer regresses to multi-second stalls on combat entry.
- [ ] Deferred orb texture-map path is visually checked for noticeable post-load pop-in on the board.
- [ ] Shared `PlayerLoadoutHud` behavior is checked in both combat and shop for slot focus, popover ownership, sell flow, and outside-click dismiss.
- [ ] Run-flow invariants are verified after refactor: no dual victory/defeat, correct boss reward routing, correct post-boss shop routing, and correct final-boss summary routing.
- [ ] Architecture-model alignment is rechecked: `docs/system_architecture.md`, `wiki/architecture.md`, and live content-loading behavior describe the same source-of-truth model.
- [ ] Temporary diagnostic instrumentation (if used) is either removed or explicitly documented as still required, with rationale.
- [ ] `get_godot_errors` is rerun after each architecture-touching batch and any stale diagnostics are cleared or called out.
- [ ] `docs/architecture_review_tasks.md`, `todo.md`, `wiki/known-issues.md`, and `wiki/log.md` are synchronized with validated outcomes.

Verification notes (2026-05-04, AR-18 architecture review closeout):
- AR-18 is the final architecture-review closeout before Milestone 10. Current validation surfaces are `res://scenes/main.tscn`, `res://scenes/combat/combat_player.tscn`, `res://scenes/flow/shop_player.tscn`, `res://scenes/flow/final_run_summary.tscn`, retained AR-01 combat result-envelope probes, RunState route probes, content contract probes, and focused scene instantiate checks. Older dated notes that mention `board_debug.tscn`, `boss_relic_reward.tscn`, `shop_placeholder.tscn`, or `run_summary_placeholder.tscn` are historical evidence from before AR-08 cleanup, not current validation guidance.
- Closeout classification: route timing baselines/post-change evidence, combat instantiate stall regression, shared HUD combat/shop behavior, RunState route invariants, dictionary-backed `ContentRegistry` alignment, per-batch Godot error checks, and tracker/wiki synchronization are covered by AR-01 through AR-18 evidence. Deferred orb texture-map pop-in, full desktop/mobile overlap sweep, seeded full-run reproducibility, Merchant Compass free-first-reroll behavior, Android audio loop-length listening, balance tuning, and first-playable run/content QA remain Milestone 10 or later QA work.
- Temporary diagnostics are intentionally retained for Milestone 10 QA: `RunState` FlowTrace logs, combat `ResolveTrace` logs, and the feature-flagged `scripts/debug/ar01_combat_result_probe.gd`. These are documented diagnostics, not new architecture ownership boundaries.
- Validation passed: `git status --short --branch` confirmed `codex/ar-18-architecture-review-closeout`; `git diff --check`; Godot MCP `get_project_info`; `view_script` for `combat_player_controller.gd`, `run_state.gd`, and `ar01_combat_result_probe.gd`; focused route/content/scene closeout probes confirming current scenes, deleted-scene absence, route constants, route invariants, and `ContentRegistry.validate_player_state_content()` returning `[]`; retained AR-01 combat result-envelope probe; and `play_scene main` with desktop menu WAV playback. Final `get_godot_errors` still carried two stale enum diagnostics from an earlier failed MCP editor-script probe; focused script refreshes passed and the rerun log showed no project runtime errors.

Verification notes (2026-05-04, post-review safety cleanup):
- Player-shop Continue and Main Menu paths now inspect the `RunState.flow_trace_change_scene(...)` return code and unlock disabled shop buttons with a visible failure status if the traced scene change fails after the button lock begins. `BoardDragInputHandler` and `CombatLayoutManager` now ignore freed node references with `is_instance_valid(...)`-based access helpers before touching cached scene nodes. (source: `scripts/flow/shop_player.gd`, `scripts/combat/board_drag_input_handler.gd`, `scripts/combat/combat_layout_manager.gd`)
- `PlayerState.orb_value(...)` no longer reaches into the `RunState` singleton directly; combat binds the run-owned `PlayerProgressionState.mastery_level(...)` provider when initializing combat or boss-reward state, while standalone `PlayerState` instances default valid orb values to `1`. Detailed combat logs now display match armor, prep armor, and total armor gain without double-counting prep armor in the formula text. (source: `scripts/combat/player_state.gd`, `scripts/combat/combat_player_controller.gd`, `scripts/combat/combat_turn_logger.gd`)
- Shared cleanup added `AudioManagerResolver` for the lazy already-open-editor `/root/AudioManager` fallback path, extended `UiUtils` with `clear_children(...)`, migrated `main_boot.gd` panel fallback styling to `UiUtils.panel_style(...)`, and removed unused duplicated combat layout constants from `combat_player_controller.gd`. Validation passed: `git diff --check`; Godot MCP `get_project_info`; `view_script` for touched runtime scripts; focused disk-source probes for `PlayerState.orb_value(...)`, `CombatTurnLogger` armor formula text, `BoardDragInputHandler` freed-board guards, `CombatLayoutManager` freed-node guards, and shop traced scene-change failure handling; scene instantiate probe for `main.tscn`, `combat_player.tscn`, `shop_player.tscn`, and `final_run_summary.tscn`; `play_scene main`; and final `get_godot_errors` reported no session errors. The editor kept stale cached versions of some pre-edit script classes during MCP probes, so the affected focused probes compiled from current disk source after `view_script` confirmed the edited files. (source: `scripts/core/audio_manager_resolver.gd`, `scripts/ui/ui_utils.gd`, `scripts/core/main_boot.gd`, `scripts/combat/combat_player_controller.gd`)

Verification notes (2026-05-03, AR-01 baseline regression harness):
- Branch/worktree baseline captured on `codex/ar-01-baseline-regression-harness`; `git status --short --branch` reported only `## codex/ar-01-baseline-regression-harness` before documentation edits, and `git diff --check` reported no whitespace errors.
- Godot MCP `get_project_info` passed: Godot `4.6.2-stable`, current project name `Orbwalker`, main scene `res://scenes/main.tscn`, autoloads `GDAIMCPRuntime`, `RunState`, and `AudioManager`.
- Initial Godot MCP `get_godot_errors` reported no session errors. After scene smokes, diagnostics reported repeated unsourced `GDScript::reload: Integer division. Decimal part will be discarded.` warnings; no fatal runtime errors were reported.
- Scene smoke baseline:
  - `res://scenes/main.tscn` via `play_scene main` launched and running tree contained `Main`, `AudioManager`, `RunState`, `LogoTexture`, `MenuButtonColumn`, `ElementRow`, `StatsPanel`, `FooterActions`, and `MainMenuMusicPlayer`; menu music log reported `AudioStreamWAV`, playing `true`, volume `-12 dB`.
  - `res://scenes/combat/combat_player.tscn` via `open_scene` + `play_scene current` launched with `CombatPlayer`, `CombatLayoutRoot`, `DebugOverlay`, and `VfxLayer`. FlowTrace baseline included `combat_first_usable_frame` at about `159ms` and deferred `combat_after_texture_map` at about `1297ms`.
  - `res://scenes/combat/board_debug.tscn` via `open_scene` + `play_scene current` launched with `BoardDebug` and its `MarginContainer`.
  - `res://scenes/flow/shop_player.tscn` via `open_scene` + `play_scene current` initialized shop scene code and music, then redirected to `res://scenes/main.tscn` because `RunState.run_active=false`; FlowTrace logged `shop_ready_redirect_before_change_scene` with details `{ "source": "no_active_run" }`.
- Focused editor-script probes:
  - Board resolver known cases passed through `BoardResolverTestRunner.run_all()`: `passed=true`, `total=8`, `failed=0`, `failures=[]`. The runner emitted expected `max_steps=1 before stabilizing` warnings for single-pass cases.
  - Combat state machine result-envelope baseline passed through `res://scripts/debug/ar01_combat_result_probe.gd` with feature flag `debug/ar01_combat_result_probe_enabled=true`: `status=ok`, `phase_before=Player Input`, `phase_after=Intent Preview`, `turn_log_has_expected_keys=true`, `missing_turn_log_keys=[]`, `combo_count=3`, `combo_count_with_bonus=3`, `heal_amount=4`, `armor_gained=9`, `gold_gained=2`, `enemy_blocked=5`, `enemy_damage_taken=19`, `total_elemental_damage=24`, `enemy_intent_skipped=false`, `player_start={hp=40,max_hp=50,armor=0,gold=0}`, `player_end={hp=42,max_hp=50,armor=0,gold=2}`, `enemy_start.hp=50`, `enemy_end.hp=31`, and `next_phase_name=Intent Preview`.
  - Combat result-envelope feature flag disabled baseline passed: `debug/ar01_combat_result_probe_enabled=false` returns `status=disabled` without running the deterministic combat probe.
  - Shop service buy/reroll/sell/booster basics passed using a local `run_state.gd` instance: `open_ok=true`, `buy_any_ok=true`, `equipment_buy_ok=true`, `reroll_ok=true`, `sell_ok=true`, `booster_buy_ok=true`, `choose_booster_ok=true`, `gold_after=975`.
  - RunState route invariants passed using a local `run_state.gd` instance: new run routes to combat; first fight victory routes to shop; shop advance routes to combat; boss victory routes through combat overlay reward; reward skip routes back to combat; final boss victory routes to `res://scenes/flow/run_summary_placeholder.tscn` with `run_active=false` and `run_victory=true`; defeat routes to `res://scenes/main.tscn` with `run_active=false` and `run_victory=false`.
  - Audio stream loading passed using a local `audio_manager.gd` node: `menu`, `combat`, and `shop` all played `AudioStreamWAV` streams at `-12 dB` with loop mode `1`; loop ends were `3223040`, `3503104`, and `1797120` respectively.
  - `PlayerLoadoutHud` selection/popover basics passed a minimal editor probe: `populate_icon_row(...)` created two equipment slots, `EquipmentSlot0` existed, and `handle_global_click(Vector2(9999, 9999))` dismissed selected inventory focus.
- Untested AR-01 scope:
  - Deferred orb texture-map visual pop-in, shared HUD sell flow in live combat/shop scenes, and manual desktop/mobile visual overlap remain manual QA items.

Debug harness note:
- `res://scripts/debug/ar01_combat_result_probe.gd` is a retained AR-01 regression helper. It is inert by default behind `debug/ar01_combat_result_probe_enabled=false`. To rerun it through Godot MCP, load the script with `ResourceLoader.CACHE_MODE_IGNORE`, set the project setting to `true`, call `run_baseline_probe()`, then set the project setting back to `false`.

Verification notes (2026-05-03, AR-02 low-risk intent snapshot fix):
- `EnemyState.get_current_intent()` now duplicates the current intent before adding the derived `index`, so callers still receive the same intent envelope while the method is explicitly non-mutating by construction.
- Godot MCP intent snapshot probe passed: stored intent-cycle entries did not gain `index` and did not receive caller-side mutations after `get_current_intent()`.
- Retained AR-01 combat result-envelope probe still matched the documented baseline: `status=ok`, `phase_before=Player Input`, `phase_after=Intent Preview`, `combo_count=3`, `heal_amount=4`, `armor_gained=9`, `gold_gained=2`, `enemy_blocked=5`, `enemy_damage_taken=19`, `total_elemental_damage=24`, `enemy_intent_skipped=false`, and `next_phase_name=Intent Preview`.
- `get_godot_errors` still reports the known unsourced `GDScript::reload: Integer division. Decimal part will be discarded.` warnings; no new fatal runtime errors were reported during this probe pass.

Verification notes (2026-05-03, AR-02 main-menu music retry poll fix):
- Main-menu music startup now stops `_process()` retry polling after successful desktop `MainMenuMusicPlayer` playback or Android/template routing through `AudioManager`, while keeping retry polling enabled if music setup fails.
- Godot MCP `view_script` and `play_scene main` passed; running scene inspection confirmed `Main` and `MainMenuMusicPlayer`, and node properties confirmed `playing=true`, `volume_db=-12.0`, `bus=Master`, and an `AudioStreamWAV` stream.
- Retained AR-01 combat result-envelope probe still matched the documented baseline after the main-menu audio change. Android/template routing was not retested on device in this pass.
- `get_godot_errors` still reports the known unsourced `GDScript::reload: Integer division. Decimal part will be discarded.` warnings; no new fatal runtime errors were reported during this probe pass.

Verification notes (2026-05-03, AR-02 audio diagnostics gate):
- Verbose `AudioManager` music startup and manual-restart diagnostics are now gated behind `debug/audio_diagnostics_enabled`, defaulting to `false`. Existing diagnostic content is preserved when the setting is enabled.
- Godot MCP fresh compile probe passed for `res://scripts/core/audio_manager.gd` with `GDScript.reload() == OK`, and a focused setting probe confirmed `false -> disabled`, `true -> enabled`, `"yes" -> enabled`, and `"off" -> disabled`.
- `play_scene main` still produced successful desktop menu music playback through `MainMenuMusicPlayer`; the default run no longer printed the verbose `AudioManager music:` diagnostic line.
- Retained AR-01 combat result-envelope probe still matched the documented baseline. `get_godot_errors` still reports the known unsourced integer-division warnings and a stale open-script parse diagnostic from the superseded audio patch; the fresh compile probe verified current `audio_manager.gd` source.

Verification notes (2026-05-03, AR-02 transition guard completion):
- Run-flow entry/exit buttons now use local duplicate-transition guards for Start Run, player-shop Continue/Menu, legacy boss-reward Skip/Continue, and legacy shop Skip/Next/Menu. Guarded controls are disabled while routing is in progress, and player-shop plus legacy reward/shop advance handlers now surface failed `RunState` transition reasons instead of changing scenes anyway.
- Godot MCP `view_script` checks passed for `res://scripts/core/main_boot.gd`, `res://scripts/flow/shop_player.gd`, `res://scripts/flow/boss_relic_reward.gd`, and `res://scripts/flow/shop_placeholder.gd`.
- Godot MCP scene instantiate probe passed for `res://scenes/main.tscn`, `res://scenes/flow/shop_player.tscn`, `res://scenes/flow/boss_relic_reward.tscn`, and `res://scenes/flow/shop_placeholder.tscn`; `get_godot_errors` reported no session errors after the script and instantiate checks.
- `play_scene main` launched the main scene and `get_scene_tree` confirmed `/root/Main`; the retained AR-01 combat result-envelope probe still matched the documented baseline with `status=ok`, `combo_count=3`, `heal_amount=4`, `armor_gained=9`, `gold_gained=2`, `enemy_blocked=5`, `enemy_damage_taken=19`, `total_elemental_damage=24`, and `next_phase_name=Intent Preview`.
- User-confirmed rapid-click QA passed for the guarded shop Main Menu flow after the audio handoff fix: returning from shop lands on main menu once, shop music stops, only main-menu music remains audible, and no new `debug/audio_diagnostics_enabled` error was observed. After the main-scene smoke, `get_godot_errors` again reported the known unsourced integer-division reload warnings.
- User rapid-click follow-up found that returning from shop to main menu could leave the shared `AudioManager` shop track audible under the desktop main menu's local `MainMenuMusicPlayer`. The desktop main-menu music path now stops any shared `AudioManager` music before starting the local menu player, while Android/template menu music still routes through `AudioManager`. `AudioManager.audio_diagnostics_opt_in_enabled()` now returns `false` without querying or registering a missing `debug/audio_diagnostics_enabled` setting, removing the reported nonexistent-setting error. Godot MCP `view_script`, focused shared-music stop probe (`before_key=shop before_playing=true after_key= after_playing=false`), diagnostics setting probe, `play_scene main`, retained AR-01 combat result-envelope probe, and `get_godot_errors` passed; only the known integer-division reload warnings remained in current session errors.

User runtime route timing capture (2026-05-03):
- `Start Run -> Combat` route `start_run_to_combat_1`: resource load `200ms`; scene instantiate `0ms`; scene attach `84ms`; `combat_first_usable_frame` at `294ms`; deferred `combat_after_texture_map` at `1409ms`.
- `Combat -> Shop` route `combat_to_shop_2`: resource load `51ms`; scene instantiate `0ms`; scene attach `114ms`; `shop_first_usable_frame` at `218ms`.
- `Shop -> Combat` route `shop_to_combat_3`: resource load `2ms`; scene instantiate `0ms`; scene attach `72ms`; `combat_first_usable_frame` at `78ms`; deferred `combat_after_texture_map` at `1206ms`.

Follow-up route timing capture (2026-05-04, derived orb texture startup fix):
- `VisualRegistry` now prefers six generated clean orb PNGs in `res://resources/art/first_pass/derived/orbs/`, while keeping runtime orb-sheet cleanup as a fallback if any derived texture is missing.
- Focused Godot MCP warm-cache probes measured `VisualRegistry.orb_texture(OrbType.Id.FIRE)` around `12ms` with a `314x314` texture.
- A live `Start Run -> Combat` trace measured resource load `232ms`, scene instantiate `1ms`, `combat_first_usable_frame` at `314ms`, and deferred `combat_after_texture_map` at `325ms`, reducing the old post-usable texture-map delay from about `1.1s-1.2s` to about `10ms` in the sampled run.
- Manual visual QA is still needed to judge visible board pop-in, Android/on-device layout, and perceived Start Run feel on target hardware.

Verification notes (2026-05-03, AR-03 shared WAV/audio utility extraction):
- `scripts/core/audio_stream_loader.gd` now owns shared file byte loading, signed PCM16 WAV parsing, imported `AudioStream` loop setup, WAV loop bounds, and source-header frame-count helpers used by both `AudioManager` and the desktop main-menu music path.
- Godot MCP post-change audio probe matched the AR-01/AR-02 baseline for music streams: `menu`, `combat`, and `shop` all played `AudioStreamWAV` at `-12 dB` with loop mode `1`, loop ends `3223040`, `3503104`, and `1797120`, and data bytes `12892160`, `14012416`, and `7188480`.
- Direct shared-loader and `main_boot._load_menu_music_stream()` probes returned the same `main-menu.wav` `AudioStreamWAV` loop end `3223040` and data bytes `12892160`; generated `swap` SFX still returned `AudioStreamWAV`, loop mode `0`, and data bytes `9700`.
- AR-02 shop-to-main-menu audio handoff probe still passed: after simulated shared shop music, stopping shared music before desktop main-menu playback reported `before_key=shop before_playing=true after_key= after_playing=false`.
- Retained AR-01 combat result-envelope probe still matched the documented baseline after the extraction. `play_scene main` launched successfully, printed desktop `Main menu music playing: android=false template=false stream=AudioStreamWAV playing=true volume_db=-12.0 bus=Master`, and `get_godot_errors` reported no session errors. Android/on-device listening and loop-length acceptance was not retested.
- User follow-up found a desktop `Start Run -> Combat` music gap during scene transition: combat music became audible on click, stopped during the screen transition, then resumed when `combat_player.tscn` finished starting. The main menu now stops its local `MainMenuMusicPlayer` and starts shared `AudioManager.play_music("combat")` before beginning the scene transition, so the autoloaded combat track can continue through loading. Godot MCP focused handoff probe passed with `before.local_playing=true`, then `after.local_playing=false`, `after.shared_key=combat`, `after.shared_playing=true`, `loop_end=3503104`, and `data_bytes=14012416`; `play_scene main` and `get_godot_errors` reported no session errors. User manual listening confirmation passed after the fix.

Verification notes (2026-05-03, AR-04 shop/input safety):
- `PlayerLoadoutHud` hover preview no longer changes committed equipment or consumable selection. Click/touch button activation remains the path that selects slots, and a selected slot survives hover exit so the popover can return to the clicked item.
- HUD Sell is gated to the currently selected hovered equipment/consumable slot, so merely hovering another filled slot does not arm a sale.
- `shop_player.gd` now guards buy, relic buy, reroll, sell, booster pick, and booster skip handlers against duplicate execution in the same process frame, while keeping later intentional presses available after the frame advances.
- Shop outside-dismissal now handles `InputEventScreenTouch` as well as left mouse clicks through the shared `PlayerLoadoutHud.handle_global_click(...)` path.
- Godot MCP checks passed: `view_script` for `res://scripts/ui/player_loadout_hud.gd` and `res://scripts/flow/shop_player.gd`; focused HUD probe reported `before=1`, `after_hover=1`, `after_exit=1`, `after_press=0`, `sell_hover_unselected=false`, `sell_hover_selected=true`, `outside_cleared=true`, and `after_outside=-1`; shop action guard probe reported `first=true`, `second_same_frame=false`; `res://scenes/flow/shop_player.tscn` instantiate returned `ok=true`; final `get_godot_errors` reported no session errors. Android/on-device touch acceptance and live visual click-through remain manual QA.
- Manual QA follow-up found outside-dismissal still failed in real shop input on PC and Android because handled UI events did not reach `_unhandled_input`. The shop scene now performs the same mouse/touch outside-dismissal check in `_input` without marking the event handled, so ordinary shop buttons still receive their input. Godot MCP `view_script`, source-shape probe, shop scene instantiate probe, and `get_godot_errors` passed after the hook change; PC and Android manual retest remains the acceptance gate.
- Manual QA follow-up 2 found the popover closed but the selected slot stayed visually selected. The outside-dismiss path now calls `_clear_inventory_focus()` and `_refresh_ui()` for mouse and touch dismissals so shop/HUD selection is cleared and slot chrome re-renders. Godot MCP `view_script` for `res://scripts/flow/shop_player.gd` and `get_godot_errors` passed. User manual QA then confirmed the outside-dismissal and visual deselection fixes on PC and Android.

Verification notes (2026-05-03, AR-05 combat controller first split):
- `scripts/combat/combat_outcome_overlay.gd` now owns standard victory/defeat outcome card presentation, boss reward card control creation/content/layout, scrim layering, overlay visibility state, and helper text wrapping. `scripts/combat/combat_player_controller.gd` still owns combat math, resolver replay timing, RunState victory/defeat/boss-reward routing, audio calls, scene changes, input phase changes, debug console commands, and `/skip`.
- Godot MCP checks passed: `view_script` for `res://scripts/combat/combat_outcome_overlay.gd` and `res://scripts/combat/combat_player_controller.gd`; focused editor-script probes confirmed helper load/methods, `res://scenes/combat/combat_player.tscn` instantiate, outcome node presence, helper boss-reward button/scrim setup, standard summary state, boss reward state, hide state, and card text wrapping; retained AR-01 combat result-envelope probe returned `status=ok` with baseline `combo_count=3`, `heal_amount=4`, `armor_gained=9`, `gold_gained=2`, `enemy_damage_taken=19`, `total_elemental_damage=24`, and `next_phase_name=Intent Preview`; final `get_godot_errors` reported no session errors.
- User manual QA confirmed normal victory `Continue`, boss reward claim and skip routing to shop, defeat overlay `Main Menu`, final boss summary routing, debug console commands including `/skip`, and the accepted resolve presentation order remained good after the split.

Verification notes (2026-05-03, AR-06 combat presentation split):
- `scripts/combat/combat_resolve_presenter.gd` now owns the board-space resolve replay presentation boundary: sorted match presentation order, match flash waits, clear burst spawning, clear/gravity/refill animation timing, delayed visual board commits, animation drain, combo popup lifecycle, and `combat_speed` duration/wait behavior. `scripts/combat/combat_player_controller.gd` still owns drag/input lifecycle, resolver simulation, combat math, mastery preview value calculation and HUD feedback decisions, RunState routing, outcome overlay routing, audio routing callbacks, scene transitions, debug console, and `/skip`.
- The callback boundary preserves the accepted trace and visible order: match flash, clear animation, visual clear commit, `combo_tick` trace, combo popup/mastery preview, gravity animation/commit, refill animation/commit. AR-08 cleanup candidates were not folded into this batch.
- Godot MCP checks passed: `view_script` for `res://scripts/combat/combat_resolve_presenter.gd` and `res://scripts/combat/combat_player_controller.gd`; `res://scenes/combat/combat_player.tscn` instantiate returned `ok=true has_outcome=true has_board=true`; retained AR-01 combat result-envelope probe returned `status=ok` with baseline `combo_count=3`, `heal_amount=4`, `armor_gained=9`, `gold_gained=2`, `enemy_damage_taken=19`, `total_elemental_damage=24`, and `next_phase_name=Intent Preview`; `play_scene main` launched successfully with main-menu WAV playback; final `get_godot_errors` reported no session errors; `git diff --check` reported no whitespace errors.
- A focused async presenter-order editor-script probe was attempted but hit an MCP tool-script parse limitation before execution. User manual QA on the installed Android build confirmed AR-06 presentation behavior works. Broader desktop/mobile overlap checks and deferred orb texture-map pop-in review remain useful outside this AR-06 acceptance pass.

Verification notes (2026-05-03, AR-07 RunState/data contract roadmap):
- `docs/system_architecture.md`, `wiki/architecture.md`, and `wiki/file-map.md` now describe the same content source-of-truth model: dictionary-backed `ContentRegistry` content is current for the prototype, while Resource/JSON migration is future work behind the registry API.
- `ContentRegistry.content_contract_snapshot()` records the current collection fields, validation ownership, shop pool/pricing ownership, and future migration boundary. `ContentRegistry` single-item getters now return duplicated dictionaries like list APIs, so caller mutation cannot alter the registry index.
- `RunState.run_contract_snapshot()` records run-owned persistence/routing fields, scene route constants, level sequence, public transition/action API names, and the content dependency boundary without changing routing behavior.
- Godot MCP checks passed: `view_script` for `res://scripts/core/run_state.gd` and `res://scripts/content/content_registry.gd`; focused content contract probe reported validation `[]`, counts `25 equipment`, `6 consumables`, `6 mastery`, `2 boosters`, `5 relics`, `3 enemies`, `3 bosses`, dictionary-backed contract source, and `single_getter_mutates_index=false`; RunState route invariant probe preserved baseline routing; retained AR-01 combat result-envelope probe still matched baseline; main/combat/board-debug/shop scene instantiate checks passed; final `get_godot_errors` reported no session errors; `git diff --check` passed.
- Manual visual QA remains required for real drag/cascade feel, visual overlap checks, Android/on-device behavior, and deferred orb texture-map pop-in; AR-07 did not retest those surfaces.

Verification notes (2026-05-03, AR-08 cleanup/dead-code validation):
- Removed only confirmed-unused dead code: `PlayerState.base_orb_values`, `CombatStateMachine.PLAYER_EFFECT_ORDER`, and unused `run_summary_placeholder.gd` helpers `_format_summary()`, `_format_slots()`, and `_format_ids()`. PowerShell source/scene reference checks found no remaining references to those removed symbols.
- Follow-up cleanup renamed the final victory summary route to `res://scenes/flow/final_run_summary.tscn`, removed the legacy boss relic reward scene/script, removed the legacy shop placeholder scene/script, and removed `res://scenes/combat/board_debug.tscn` plus its controller. Boss reward option/claim/skip APIs and the `boss_relic_reward` run step key remain because the combat victory overlay still uses them.
- Godot MCP checks passed: `view_script` for `res://scripts/combat/player_state.gd`, `res://scripts/combat/combat_state_machine.gd`, `res://scripts/core/run_state.gd`, `res://scripts/combat/combat_player_controller.gd`, and `res://scripts/flow/final_run_summary.gd`; final `get_godot_errors` reported no session errors.
- Retained AR-01 combat result-envelope probe still matched baseline: `status=ok`, `phase_before=Player Input`, `phase_after=Intent Preview`, `combo_count=3`, `heal_amount=4`, `armor_gained=9`, `gold_gained=2`, `enemy_blocked=5`, `enemy_damage_taken=19`, `total_elemental_damage=24`, `enemy_intent_skipped=false`, and `next_phase_name=Intent Preview`.
- RunState route probes preserved baseline route shapes: new run routes to combat; first fight victory routes to shop; shop advance routes to combat; boss reward remains in combat overlay route with reward skip advancing to shop; final boss victory routes to `res://scenes/flow/final_run_summary.tscn` with `run_active=false` and `run_victory=true`; defeat now routes to `res://scenes/flow/final_run_summary.tscn` with `run_active=false` and `run_victory=false`, while reset/no-summary inactive state still routes to `res://scenes/main.tscn`.
- Scene instantiate probe passed for `res://scenes/main.tscn`, `res://scenes/combat/combat_player.tscn`, `res://scenes/flow/shop_player.tscn`, and `res://scenes/flow/final_run_summary.tscn`; deleted-scene source reference checks found no remaining runtime references to `run_summary_placeholder`, `boss_relic_reward.tscn`, `shop_placeholder.tscn`, or `board_debug.tscn`; `play_scene main` launched successfully; `git diff --check` passed.
- Godot MCP follow-up for the defeat summary route correction passed: focused `RunState` probe confirmed reset inactive routes to `res://scenes/main.tscn`, new run routes to combat, finalized defeat routes to `res://scenes/flow/final_run_summary.tscn` with a non-empty defeat summary, scene instantiate still passes for main/combat/shop/final summary, retained AR-01 combat result-envelope probe still matches baseline, `play_scene main` launched with no session errors, and `git diff --check` passed.
- Manual visual QA remains required for real drag/cascade feel, visual overlap checks, Android/on-device behavior, and deferred orb texture-map pop-in; AR-08 did not retest those surfaces.

Verification notes (2026-05-03, AR-09 stability and shared UI utility cleanup):
- `scripts/combat/combat_player_controller.gd` now guards async resolve/turn replay continuations before final board commits or outcome routing, and the wrong-step combat redirect uses `RunState.flow_trace_change_scene(...)` instead of a bare deferred scene change.
- `scripts/combat/combat_resolve_presenter.gd` now validates timer owner, scene tree, and board view after waits and before touching bound nodes. Its final animation drain exits on invalid lifecycle state or a bounded timeout/iteration cap instead of waiting forever on stuck `has_active_animations()`.
- `scripts/core/main_boot.gd` now handles failed Start Run scene transitions by re-enabling `Start Run`, clearing `_start_run_transitioning`, showing status text, and logging the failure while preserving the existing combat music handoff before successful transitions.
- `scripts/flow/final_run_summary.gd` now locks and disables `Start New Run` / `Main Menu` actions while routing, and uses traced `RunState.flow_trace_change_scene(...)` with failure recovery. `scripts/ui/ui_utils.gd` now owns the shared `UiUtils.panel_style(...)` helper used by `shop_player.gd` and `final_run_summary.gd`, preserving the previous radius, border-width, and margin mapping.
- Validation passed: `git diff --check`; Godot MCP `get_project_info`; `view_script` for `combat_player_controller.gd`, `combat_resolve_presenter.gd`, `main_boot.gd`, `final_run_summary.gd`, `shop_player.gd`, and `ui_utils.gd`; `get_godot_errors` with no session errors; focused scene instantiate probe for `main.tscn`, `combat_player.tscn`, and `final_run_summary.tscn`; focused `UiUtils.panel_style(...)` probe confirming border/radius/margin mapping; and `play_scene main` smoke with desktop menu WAV playback and no session errors.
- User manual sanity QA on 2026-05-04 confirmed the AR-09 checklist is good: Start Run reaches combat, combat resolve/cascade feel and routing remain acceptable, final-summary actions behave correctly under sanity testing, shop regression checks passed, and migrated shop/final-summary panel styling still looks correct. Android/on-device behavior, full viewport overlap sweep, and deferred orb texture-map pop-in remain broader manual QA unless retested separately.

Verification notes (2026-05-04, AR-10 combat controller god-object refactor):
- `scripts/combat/combat_debug_console.gd` now owns debug command parsing/dispatch, command help/error text, log-level state, combat log storage/rendering, line cap, and command-output coloring. `scripts/combat/combat_turn_logger.gd` now owns normal/detailed turn-log line generation, state snapshot formatting helpers, intent text formatting, and reusable turn/victory/defeat/run-summary strings.
- `scripts/combat/combat_player_controller.gd` still owns privileged gameplay actions and stateful callbacks: `/skip` route/state reset, board reroll/seed, RunState/progression mutations, HUD refresh, debug fight win/lose outcome routing, input, resolve presentation, VFX, layout, audio hooks, and scene transitions.
- Validation passed: `git diff --check`; Godot MCP `get_project_info`; `view_script` for `combat_player_controller.gd`, `combat_debug_console.gd`, and `combat_turn_logger.gd`; focused `ResourceLoader.CACHE_MODE_IGNORE` script-load probe for all three scripts; focused `combat_player.tscn` instantiate probe confirming `DebugOverlay`, `CombatLogText`, `ConsoleInput`, `BoardSurface`, and `OutcomeSummaryPanel`; retained AR-01 combat result-envelope probe still matched baseline values; focused turn-logger parity probe matched the known normal turn log and summary string; `play_scene main` launched with desktop menu WAV playback; final `get_godot_errors` reported no session errors after rerun.
- A broader focused debug-console command probe using inline lambdas returned `<null>` through the MCP editor-script environment, so live representative command click-through remains manual QA. Android/on-device behavior, real drag/cascade feel, visual overlap checks, deferred orb texture-map pop-in, and rapid-tap feel were not retested in AR-10.

Verification notes (2026-05-04, AR-11 combat layout manager extraction):
- `scripts/combat/combat_layout_manager.gd` now owns combat-scene layout orchestration: design-root scaling, runtime rect calculation, enemy panel layout, combat strip timer geometry, board panel aspect/shadow layout, player panel positioning/legacy visibility, loadout rail positioning through `PlayerLoadoutHud`, debug overlay anchors, and outcome overlay board-rect sync. `scripts/combat/combat_player_controller.gd` keeps gameplay state, scene ownership, input, timer state decisions, HUD data refresh, VFX, resolve presentation, audio, `/skip`, debug callbacks, outcome routing, and scene transitions.
- Validation passed: `git diff --check`; Godot MCP `view_script` for `combat_player_controller.gd`, `combat_layout_manager.gd`, and `player_loadout_hud.gd`; focused helper reload returned `reload=0 base=RefCounted new=true`; `combat_player.tscn` instantiate confirmed `CombatLayoutRoot`, `BoardPanel`, `BoardSurface`, `PlayerHudSection`, `DebugOverlay`, and `OutcomeSummaryPanel`; layout probe preserved `1080x1920` board `480x576`, `1080x2400` board `880x1056`, tall board panel `1048x1064`, and wide debug anchor behavior; retained AR-01 combat result-envelope probe still matched baseline values; `play_scene main` launched with desktop menu WAV playback; final `get_godot_errors` reported no session errors.
- Manual visual QA remains required for overlap checks, Android/on-device layout, drag/cascade feel, deferred orb texture-map pop-in, and rapid-tap feel.

Verification notes (2026-05-04, AR-12 combat VFX manager extraction):
- `scripts/combat/combat_vfx_manager.gd` now owns combat VFX layer binding, texture VFX spawning, replay impact texture lookup/fallback, mastery beam source lookup through `PlayerLoadoutHud`, global-to-VFX-layer coordinate conversion, beam sizing/rotation/z-index, and fade cleanup. `scripts/combat/combat_player_controller.gd` keeps turn-log decisions, replay order, waits, combat speed timing, mastery preview totals/release semantics, resolver simulation, combat math, input, layout, audio, debug callbacks, `/skip`, outcome routing, and scene transitions.
- Validation passed: `git diff --check`; Godot MCP `get_project_info`; `view_script` for `combat_player_controller.gd` and `combat_vfx_manager.gd`; focused helper reload/instantiate probe returned `reload=0 base=RefCounted new=true`; focused helper VFX probe confirmed null texture no-op, spawned texture parenting under `VfxLayer`, size preservation, and alpha modulation; `combat_player.tscn` instantiate confirmed `VfxLayer`, `ElementalMasteryCards`, `EnemyPortrait`, `PlayerPortrait`, and `BoardSurface`; retained AR-01 combat result-envelope probe still matched baseline values; `play_scene main` launched with desktop menu WAV playback; final `get_godot_errors` reported no session errors.
- Manual visual QA remains required for real mastery beams, impact placement, cascade readability, Android/on-device behavior, overlap checks, drag/cascade feel, orb texture pop-in, and rapid-tap feel.

Verification notes (2026-05-04, AR-13 board drag input handler extraction):
- `scripts/combat/board_drag_input_handler.gd` now owns board-local mouse/touch input parsing, active drag state, touch-index tracking, selected orb/current cell/path tracking, adjacent-cell swap bookkeeping, move-timer countdown state, drag visual reset/abort, and live match-glow refresh. `scripts/combat/combat_player_controller.gd` keeps input phase ownership, timer/status rendering, swap SFX callback policy, resolve kickoff, visual/simulation board cloning, combat math, resolve presentation, HUD sync, VFX, layout, debug callbacks, `/skip`, outcome routing, and scene transitions.
- Validation passed: `git diff --check`; Godot MCP `view_script` for `combat_player_controller.gd` and `board_drag_input_handler.gd`; focused script-load probe returned controller base `Control` and helper base `RefCounted`; focused helper probes confirmed local coordinate round trip for cell `(2, 4)`, valid drag start, adjacent move swap, invalid start rejection, invalid/non-adjacent move rejection without board mutation, release end action, reset visual state, touch start/second-touch rejection/touch-drag/touch-end behavior, and timeout end action; `combat_player.tscn` instantiated with `CombatLayoutRoot` and `BoardSurface`; retained AR-01 combat result-envelope probe still matched baseline values; `play_scene main` launched with desktop menu WAV playback; final `get_godot_errors` reported no session errors.
- Android deployment: exported `D:\godot\matchatro\Orbwalker.apk` and installed it to connected device `b21e3ea8` with `adb install -r`; package verification reported `package:com.example.orbwalker`.
- User manual QA confirmed real mouse drag, Android touch drag, rapid-tap feel, cascade feel after drag release, and board coordinate accuracy passed.

Verification notes (2026-05-04, AR-14 combat theme and chrome boundary):
- `scripts/combat/combat_chrome_styler.gd` now owns code-built combat chrome/style construction for shared combat frame styleboxes, progress bars, label font/color overrides, timer-track and timer-label readability styling, buttons, board/outcome panel chrome, stat chips, debug overlay font sizing, shared player-HUD chrome dispatch, and debug zone-guide chrome. `scripts/combat/combat_player_controller.gd` keeps scene-node ownership, `_apply_visual_chrome()` orchestration, timer runtime text/fill/color math, placeholder texture creation/assignment, layout, VFX, input, combat math, resolve presentation, route transitions, debug callbacks, and `/skip`.
- Validation passed: `git diff --check`; Godot MCP `get_project_info`; `view_script` for `combat_player_controller.gd` and `combat_chrome_styler.gd`; focused script-load probe returned controller base `Control`, helper reload `0`, and helper base `RefCounted`; `combat_player.tscn` instantiated with `CombatLayoutRoot`, `BoardSurface`, `TimerTrack`, and `OutcomeSummaryPanel`; focused style probe confirmed representative pre-refactor shared frame, timer track, timer font/outline/shadow, and enemy HP fill values; retained AR-01 combat result-envelope probe still matched baseline values; `play_scene main` launched with desktop menu WAV playback; final `get_godot_errors` reported no session errors.
- User manual QA passed after the helper extraction. AR-14 did not otherwise change or retest real drag/cascade feel, Android touch input mechanics, combat math, resolve presentation timing, route transitions, or `/skip`.

Verification notes (2026-05-04, AR-15 combat placeholder texture utility):
- `scripts/combat/combat_placeholder_textures.gd` now owns only the code-generated timer, intent, enemy portrait, and hero portrait placeholder `ImageTexture` builders. `scripts/combat/combat_player_controller.gd` keeps the fallback decisions, `VisualRegistry` lookup calls, node assignment, visibility toggles, portrait refresh timing, timer runtime behavior, layout, chrome styling, combat math, resolve presentation, route transitions, debug callbacks, and `/skip`.
- Validation passed: `git diff --check`; Godot MCP `get_project_info`; `view_script` for `combat_player_controller.gd` and `combat_placeholder_textures.gd`; focused texture probe confirmed timer `96x96`, intent `96x96`, enemy `260x230`, and hero `192x192` placeholder dimensions plus representative sampled colors/alpha values; focused script-load and scene instantiate probe returned controller base `Control`, helper base `RefCounted`, and confirmed `TimerIcon`, `IntentBadge`, `EnemyPortrait`, `PlayerPortrait`, and `BoardSurface` in `combat_player.tscn`; retained AR-01 combat result-envelope probe still matched baseline values; `play_scene main` launched with desktop menu WAV playback; final `get_godot_errors` reported no session errors.
- A separate async scene-ready texture-assignment probe hit an MCP tool-script parse limitation before execution. User manual QA passed after the helper extraction. AR-15 did not otherwise change or retest drag/cascade feel, combat math, resolve presentation timing, route transitions, Android behavior, or `/skip`.

Verification notes (2026-05-04, AR-16 combat HUD sync boundary):
- `scripts/combat/combat_hud_snapshot_builder.gd` now owns side-effect-free combat HUD snapshot dictionary construction for top HUD, enemy stage, timer/tempo row, player strip, and debug overlay data. `scripts/combat/combat_player_controller.gd` still applies those snapshots to scene labels/bars/nodes, dispatches the `PlayerLoadoutHud` payload, reapplies loadout rail layout, assigns placeholder fallbacks, and owns combat-only enemy/timer/status behavior.
- Validation passed: `git diff --check`; Godot MCP `get_project_info`; `view_script` for `combat_player_controller.gd` and `combat_hud_snapshot_builder.gd`; focused HUD snapshot probe returned helper base `RefCounted`, controller base `Control`, instantiated combat and shop scenes, and confirmed representative title/gold, enemy HP/block, timer state/seconds, player HP/armor/stat, truncated turn-summary, and debug status strings; retained AR-01 combat result-envelope probe still matched baseline values; `play_scene main` launched with desktop menu WAV playback; final `get_godot_errors` reported no session errors.
- User manual QA passed after the HUD snapshot boundary extraction, covering the AR-16 combat/shop HUD acceptance surface. AR-16 did not otherwise change or retest combat math, resolve presentation timing, routing, input handling, VFX, layout formulas, audio behavior, debug command output, Android export/install, or `/skip` internals.

Verification notes (2026-05-04, AR-17 combat outcome and transition boundary review):
- `scripts/combat/combat_player_controller.gd` now centralizes duplicated combat outcome trace/change-scene glue in `_trace_and_change_scene_to_target(...)`, used by the standard outcome Next button, boss reward claim, and boss reward skip paths. `RunState` still owns route semantics, boss reward state, final summary routing, and run summaries; `CombatOutcomeOverlay` still owns only presentation state/layout/content.
- Validation passed: `git status --short --branch` confirmed `codex/ar-17-combat-outcome-transition-boundary`; `git diff --check`; Godot MCP `get_project_info`; `view_script` for `combat_player_controller.gd`; focused RunState route invariant probe preserved normal victory to shop, shop advance to combat, boss victory to combat-hosted boss reward, boss reward skip to shop, final boss victory to `res://scenes/flow/final_run_summary.tscn`, and defeat to `res://scenes/flow/final_run_summary.tscn`; scene instantiate probe passed for `combat_player.tscn`, `shop_player.tscn`, and `final_run_summary.tscn`; retained AR-01 combat result-envelope probe still matched baseline values; `play_scene main` launched with desktop menu WAV playback; final `get_godot_errors` reported no session errors.
- User manual QA passed with no issues and no errors after checking normal victory continue, boss reward claim/skip, final boss summary, defeat summary, debug fight win/lose, and main-menu return behavior. AR-17 did not change combat math, resolve presentation timing, overlay layout, audio priority, input handling, VFX, layout formulas, debug command output, `/skip`, or RunState route contracts.
