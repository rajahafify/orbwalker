# Orbwalker Execution Todo

Source GDD: `docs/game_design_document.md`  
Created: 2026-04-26  
Target: First playable prototype vertical slice from the GDD.

## Current Project State

- Godot project exists and is configured as `Orbwalker`.
- `docs/game_design_document.md` defines the game direction and first playable scope.
- `scripts/` exists but currently has no gameplay scripts.
- No gameplay scenes, board implementation, combat loop, shop, or content data files are present yet.

## Execution Strategy

Build the prototype in layers. Keep board and combat logic deterministic and testable before relying on presentation. Use data-driven definitions for items, enemies, bosses, relics, consumables, and shop pools so balance can change without rewriting core systems.

Core implementation targets:

- Godot 4.6 project.
- One hero.
- 3 dungeon levels for the first playable prototype.
- 5 columns x 6 rows board.
- 6 orb types: Fire, Ice, Earth, Heart, Armor, Gold.
- Puzzle & Dragons style free orb movement.
- 5 second movement timer.
- Same-type straight, L, and T matching.
- Cascades with combo counting.
- Turn-based enemy intent combat.
- Persistent HP and gold across the run.
- Shop after each fight.
- 20 to 30 equipment items, 6 mastery cards, 6 consumables, 5 relics.
- At least 3 normal enemies and 3 bosses.

## Status Legend

- `[ ]` Not started.
- `[~]` In progress.
- `[x]` Complete.
- `[!]` Blocked or needs design decision.

## Milestone 0: Production Baseline And Scope Lock

Status: Complete.

Goal: Turn the GDD into an executable implementation shape and prepare the project for feature work.

Primary deliverable: A Godot project that opens to a debug start scene, has an agreed folder structure, and has clear data and code ownership for the prototype systems.

Tasks:

- [x] Confirm prototype scope from the GDD.
  - Deliverable: `todo.md` is accepted as the execution plan for the first playable prototype. Scope confirmation is documented in `docs/system_architecture.md`.
  - Acceptance: The prototype target is explicitly 3 dungeon levels, one hero, one dungeon, and the GDD feature list under "First Playable Prototype Scope".

- [x] Document proposed project folder structure.
  - Deliverable: Proposed folders such as `scenes/`, `scripts/core/`, `scripts/board/`, `scripts/combat/`, `scripts/run/`, `scripts/shop/`, `scripts/ui/`, `scripts/content/`, `resources/`, `resources/items/`, `resources/enemies/`, and `resources/relics/` are documented in `docs/system_architecture.md`.
  - Acceptance: New gameplay files have obvious homes and avoid mixing data, UI, and simulation code.

- [x] Create project folder structure.
  - Deliverable: Actual project folders matching the approved structure.
  - Acceptance: Folder creation is complete without adding gameplay code.
  - Note: Created under `scenes/`, `scripts/`, and `resources/` based on the approved structure.

- [x] Create a minimal boot scene.
  - Deliverable: `res://scenes/main.tscn` or equivalent main scene configured in `project.godot`.
  - Acceptance: Running the project opens a simple prototype entry point with a "start fight" or direct debug fight path.
  - Note: `scenes/main.tscn` and `scripts/core/main_boot.gd` were added, and `run/main_scene` now points to this scene.

- [x] Decide the data format for content.
  - Deliverable: Resource class plan for equipment, mastery cards, consumables, relics, enemies, bosses, booster packs, and shop pricing. Documented in `docs/system_architecture.md`.
  - Acceptance: Each content type can be created as data without custom code per item, except when a unique effect needs a scripted hook.

- [x] Define core runtime state models.
  - Deliverable: Planned classes for `BoardState`, `RunState`, `PlayerState`, `EnemyState`, `CombatState`, `ShopState`, and `ContentRegistry`. Documented in `docs/system_architecture.md`.
  - Acceptance: The project can separate persistent run state from temporary fight state and UI state.

- [x] Define event and effect timing.
  - Deliverable: A documented combat event order matching the GDD: match resolution, heart healing, armor gain, elemental damage, gold gain, enemy death check, enemy intent, armor expiration. Documented in `docs/system_architecture.md`.
  - Acceptance: Equipment and relic effects can attach to clear timing points without hardcoding every item into the combat loop.

- [x] Add a manual QA checklist.
  - Deliverable: `docs/test_plan.md` or a section in this file listing repeatable smoke tests.
  - Acceptance: Every milestone can be validated with specific play steps.

## Milestone 1: Board Foundation

Status: Complete.

Goal: Implement a deterministic 5x6 orb board that can render, refill, and avoid initial automatic matches.

Primary deliverable: A visible 5x6 board with all six orb types, configurable spawn weights, and no automatic matches on newly generated starting boards.

Tasks:

- [x] Implement orb type definitions.
  - Deliverable: `OrbType` enum or equivalent constants for Fire, Ice, Earth, Heart, Armor, and Gold.
  - Acceptance: All systems refer to one canonical orb type definition.

- [x] Implement board data model.
  - Deliverable: `BoardState` with 5 columns, 6 rows, cell read/write helpers, bounds checks, cloning, and deterministic random generation.
  - Acceptance: Board logic can run without UI nodes.

- [x] Add configurable spawn weights.
  - Deliverable: Board generation settings with Gold rarer than other orb types.
  - Acceptance: Gold spawn rate can be adjusted for balance without changing board logic.

- [x] Prevent initial automatic matches.
  - Deliverable: Board generator that retries or repairs generated boards until no starting match exists.
  - Acceptance: A new fight never begins with an immediate match already on the board.

- [x] Render the board.
  - Deliverable: Board scene showing a stable 5x6 grid and one visual orb per cell.
  - Acceptance: The board fits desktop and mobile aspect ratios without stretched or overlapping cells.

- [x] Add debug board controls.
  - Deliverable: Debug actions for regenerate board, print board state, and optionally set a fixed seed.
  - Acceptance: Developers can reproduce board bugs using a known seed or printed board layout.

## Milestone 2: Free Orb Movement And Timer

Goal: Implement Puzzle & Dragons style drag movement with a 5 second timer.

Primary deliverable: The player can select one orb, drag through adjacent orthogonal cells, displace orbs along the path, and end movement by release or timer expiry.

Tasks:

- [x] Implement pointer and touch selection.
  - Deliverable: Input handler that maps mouse or touch coordinates to board cells.
  - Acceptance: The same board can be controlled on PC with a mouse and on mobile with touch.

- [x] Implement selected orb state.
  - Deliverable: The selected orb is tracked separately during drag while the board updates displaced cells.
  - Acceptance: The dragged orb follows the pointer and the board cells update predictably.

- [x] Implement orthogonal path movement.
  - Deliverable: Movement through adjacent horizontal and vertical cells only.
  - Acceptance: Diagonal movement does not swap cells and cannot skip cells.

- [x] Implement displacement swapping.
  - Deliverable: Each entered adjacent cell swaps or shifts with the selected orb according to the GDD movement rule.
  - Acceptance: Dragging through a path produces the same final board that a Puzzle & Dragons style player expects.

- [x] Implement 5 second movement timer.
  - Deliverable: Timer starts on drag start and ends the move on expiry.
  - Acceptance: Releasing early or timer expiry both lock the board and start match resolution.

- [x] Add movement feedback.
  - Deliverable: Selected orb highlight, timer display, and optional path or cell feedback.
  - Acceptance: The player can read which orb is selected and how much time remains.

- [~] Add input lock states.
  - Deliverable: Board ignores new drag input while matches, cascades, combat, shop, or transitions are resolving.
  - Acceptance: The player cannot mutate the board during non-input phases.

## Milestone 3: Match Detection, Clear, Gravity, And Cascades

Status: In progress.

Goal: Resolve all valid matches and cascades exactly according to the GDD.

Primary deliverable: A deterministic match resolver that handles horizontal, vertical, L, and T matches, clears matched orbs, applies gravity, refills from the top, and repeats until stable.

Tasks:

- [x] Implement horizontal and vertical run detection.
  - Deliverable: Match scanner for same-type straight lines of 3 or more.
  - Acceptance: Lines of 3, 4, 5, and 6 are detected correctly in every row and column.

- [x] Implement L and T shape support.
  - Deliverable: Connected same-type horizontal and vertical runs are merged into one match component.
  - Acceptance: L and T matches count as valid matches and diagonal-only connections do not count.

- [x] Define combo counting.
  - Deliverable: Resolver output that returns total combo count and matched orb counts by orb type.
  - Acceptance: Separate connected match groups count as separate combos, including cascade combos.

- [x] Clear matched orbs.
  - Deliverable: Matched cells are removed after each resolver pass.
  - Acceptance: All cells belonging to valid match components are cleared exactly once.

- [x] Apply gravity.
  - Deliverable: Existing orbs fall down into empty cells after clears.
  - Acceptance: Gravity is down only and preserves the order of falling orbs in each column.

- [x] Refill from the top.
  - Deliverable: New orbs enter empty cells from above using configured spawn weights.
  - Acceptance: Refill can immediately create cascades and those cascades are resolved.

- [x] Add resolver animation hooks.
  - Deliverable: Events for match found, clear, fall, refill, and cascade complete.
  - Acceptance: Logic can run instantly for tests and with animations for gameplay.

- [x] Add board resolver tests.
  - Deliverable: Test scenes or scripts for line, L, T, no diagonal, cascade, gravity, and refill cases.
  - Acceptance: Known board layouts produce expected combo counts and orb totals.

## Milestone 4: Core Combat Loop

Status: Complete.

Goal: Convert match results into healing, armor, damage, gold, and enemy intent resolution.

Primary deliverable: A complete single-fight loop with persistent player HP, enemy intent preview, armor behavior, enemy block, enemy death, and next-turn flow.

Tasks:

- [x] Implement player state.
  - Deliverable: `PlayerState` with max HP, current HP, armor, gold, base orb values, equipment slots, consumable slots, and move timer.
  - Acceptance: HP persists across fights and armor is temporary by default.

- [x] Implement enemy state and intents.
  - Deliverable: Enemy data with HP, move cycle, current intent, attack value, and block value.
  - Acceptance: Enemy intent is visible before the player moves.

- [x] Implement combat state machine.
  - Deliverable: Phases for intent preview, player input, match resolution, player effects, enemy response, cleanup, victory, and defeat.
  - Acceptance: The game always advances through the GDD turn order.

- [x] Apply heart healing.
  - Deliverable: Heart matches heal by matched heart orbs times current heart base value.
  - Acceptance: Healing does not exceed max HP unless a future effect explicitly allows it.

- [x] Apply armor gain.
  - Deliverable: Armor matches add temporary armor by matched armor orbs times current armor base value.
  - Acceptance: Armor blocks incoming damage before HP and expires after enemy action by default.

- [x] Apply elemental damage.
  - Deliverable: Fire, Ice, and Earth damage uses `matched_element_orbs * element_base_value * total_combo_count`.
  - Acceptance: Heart, Armor, and Gold do not use combo scaling by default.

- [x] Apply gold gain.
  - Deliverable: Gold matches increase run gold by matched gold orbs times current gold base value.
  - Acceptance: Gold persists for the run and normal enemies do not need automatic gold drops.

- [x] Apply enemy block.
  - Deliverable: Enemy block intent reduces incoming player damage for the current turn only.
  - Acceptance: Enemy block does not persist unless a future rule says it should.

- [x] Resolve enemy death before enemy intent.
  - Deliverable: Enemy attack is skipped if damage kills the enemy.
  - Acceptance: A lethal player turn prevents all remaining enemy intent from resolving.

- [x] Implement defeat and victory outcomes.
  - Deliverable: Fight ends cleanly on player death or enemy death.
  - Acceptance: Victory transitions to shop or boss reward, defeat transitions to run summary.

Verification notes (2026-04-26):
- Added `PlayerState`, `EnemyState`, and `CombatStateMachine` runtime models, plus `RunState` autoload persistence for cross-fight HP and gold.
- Combat debug scene now shows enemy intent, phase, player/enemy stats, and a detailed combat log for turn-by-turn formula verification.
- Enemy death now waits for manual confirmation through a `Next` button before transitioning to post-battle reward.
- Godot MCP script validation passed for enemy block reduction, lethal-before-intent skip, armor blocking and expiration, and healing clamp to max HP.

## Milestone 5: Player State Management

Status: Complete.

Goal: Implement a clear player-state runtime for progression systems with explicit acceptance gates.

Primary deliverable: A canonical `PlayerProgressionState` (or equivalent) plus validated state transitions for equipment, mastery, consumables, and relics.

Tasks:

- [x] Phase A: Define player-state contracts.
  - Deliverable: Canonical runtime and data structures for 5 equipment slots, 3 consumable slots, persistent relic list, and 6 mastery tracks with cap 5.
  - Acceptance: All fields have documented ownership, defaults, and run persistence behavior through `RunState`.

- [x] Phase B: Implement player-state transitions.
  - Deliverable: Action interfaces or services for `equip_item`, `unequip_item`, `sell_equipment`, `grant_mastery`, `add_consumable`, `use_consumable`, and `add_relic`.
  - Acceptance: Each action defines deterministic preconditions and postconditions, and rejects invalid operations with explicit reasons.

- [x] Phase C: Scope effects to player-state actions.
  - Deliverable: Milestone 5 effect coverage limited to hooks needed by equipment, consumable, and relic state actions.
  - Acceptance: Equipment and relic effects apply only while active, and player-state actions do not require combat-specific hardcoded special cases.

- [x] Phase D: Validate data and expose debug state.
  - Deliverable: Content checks for duplicate IDs, missing display data, and invalid effect references used by player-state content.
  - Deliverable: Standard validation result format as an error list with `item_id` and `reason`.
  - Deliverable: Debug visibility for current player-state snapshot during playtest.
  - Acceptance: Invalid content is reported before run entry and active player progression state can be inspected at runtime.

## Milestone 6: Shop, Economy, And Boosters

Status: In progress.

Goal: Build the post-fight shop loop and the economy around matched gold.

Primary deliverable: After each fight, the player enters a shop with 3 random item slots, 1 relic offer for the dungeon level, reroll, boosters, buying, selling, and skipping.

Tasks:

- [x] Implement persistent run gold.
  - Deliverable: Gold is stored in `RunState` and displayed in combat and shop.
  - Acceptance: Gold earned in fights is available in later shops.

- [x] Implement shop generation.
  - Deliverable: Shop inventory with 3 random item slots and 1 relic offer per dungeon level.
  - Acceptance: The relic offer is lost if not bought before leaving that dungeon level.

- [x] Implement pricing rules.
  - Deliverable: Configurable price ranges by rarity and dungeon level, plus reroll cost.
  - Acceptance: Price balance can be adjusted without changing shop UI code.

- [x] Implement buy action.
  - Deliverable: Player can buy equipment, mastery cards, consumables, boosters, and relics when they can afford them.
  - Acceptance: Buying subtracts gold, applies the item or moves it into the correct inventory, and prevents invalid purchases.

- [x] Implement sell equipment action.
  - Deliverable: Equipped items can be sold for full gold value.
  - Acceptance: Selling removes the equipment, removes its passive effects, and refunds the correct amount.

- [x] Implement shop reroll.
  - Deliverable: Reroll replaces random item slots and respects reroll cost.
  - Acceptance: Relic offer behavior is explicitly decided and implemented: either fixed for the dungeon level or rerolled only if the GDD is updated.

- [x] Implement booster pack purchase.
  - Deliverable: Buying a booster opens a pack view with 3 generated options and allows the player to pick 1.
  - Acceptance: Boosters can generate element-based or category-based options and do not generate relics by default; full equipment or consumable inventories leave the player HUD usable and provide a clear Skip path instead of blocking shop progression.

- [~] Tune early affordability.
  - Deliverable: Initial price and gold spawn settings.
  - Acceptance: After the first enemy, a player who matched some gold can usually afford at least 1 booster pack.

Verification notes (2026-04-26):
- Added `ShopState` and `ShopService` runtime systems under `scripts/shop/` for shop open, item/relic offers, buy, sell, reroll, and booster option pick flow.
- `RunState` now owns persistent run gold (`run_gold`) and exposes shop/economy actions consumed by combat and shop UI.
- Combat gold gain now syncs through `RunState`, and the shop scene moved from placeholder text to actionable debug controls.
- Debug content and pricing scaffolding were extended in `ContentRegistry` to support Milestone 6 shop generation and purchase paths.
- Fixed strict typing parse break in `scripts/debug/board_debug_controller.gd` by using explicit `Variant` locals for `RunState` service retrieval in debug add-item actions.
- 2026-05-02 shop UX follow-up: pending booster choices no longer block the shared player HUD, full-slot picks tell the player to sell from the loadout HUD or skip, and `shop_player.gd` now shows a contextual sell bubble near the selected equipment or consumable slot instead of a permanent action-row sell button.

## Milestone 7: Dungeon And Run Structure

Status: Complete.

Goal: Turn isolated fights and shops into a 3-level first playable run.

Primary deliverable: A complete 3 dungeon level run with normal enemies, shops, bosses, boss relic rewards, death, and victory.

Tasks:

- [x] Implement run start.
  - Deliverable: New run initializes one hero, starting stats, starting gold, empty inventories, and level 1 dungeon state.
  - Acceptance: Starting a new run produces a clean state every time.

- [x] Implement dungeon level sequence.
  - Deliverable: Each level follows Enemy 1, Shop, Enemy 2, Shop, Boss, Boss Relic Reward, Shop, Advance.
  - Acceptance: The game advances through the sequence without manual debug intervention.

- [x] Implement 3-level prototype run.
  - Deliverable: Level counter and run completion after level 3 boss and final shop or victory screen.
  - Acceptance: The vertical slice can be completed from start to finish.

- [x] Add boss preview.
  - Deliverable: Boss type is visible at the start of each dungeon level.
  - Acceptance: The player knows the level boss check before committing to shop and fight decisions.

- [x] Implement boss relic reward.
  - Deliverable: Boss victory grants or offers a relic reward before the next shop.
  - Acceptance: Boss relics are separate from shop relic offers and are selected or explicitly skipped from the combat victory overlay before the shop transition.

- [x] Implement defeat summary.
  - Deliverable: Run loss screen showing level reached, enemies defeated, gold earned, equipped items, relics, and cause of death.
  - Acceptance: Player death exits the run cleanly.

- [x] Implement prototype victory summary.
  - Deliverable: Run win screen after clearing the prototype final boss.
  - Acceptance: Clearing all 3 levels produces a complete win state.

Verification notes (2026-04-27):
- Godot MCP sequence validation passed for run start, level sequence transitions, boss reward step, prototype victory transition, and defeat summary transition.
- Run sequencing is now owned by `RunState` and consumed by combat/shop/summary scenes instead of hard-coded placeholder jumps.
- 2026-05-02 dungeon playthrough fix: normal player-facing boss reward routing stays in `combat_player.tscn` for the victory overlay picker, then advances to the post-boss shop; the old boss relic scene is retained only as legacy/debug fallback.

## Milestone 8: Initial Content Pack

Status: Complete.

Goal: Fill the prototype with enough content to exercise the build-driven roguelike loop.

Primary deliverable: A data-driven content pack matching the GDD initial lists.

Tasks:

- [x] Implement 6 mastery cards.
  - Deliverable: Fire, Ice, Earth, Heart, Armor, and Gold mastery cards.
  - Acceptance: Each card increases its mastery by 1 up to the prototype cap.

- [x] Implement 6 consumables.
  - Deliverable: Fire Scroll, Ice Scroll, Earth Scroll, Heart Scroll, Armor Scroll, and Gold Scroll.
  - Acceptance: Each scroll converts the correct number of random non-target orbs.

- [x] Implement common equipment.
  - Deliverable: Shortsword, Buckler, Coin Purse, Healing Charm, Ember Ring, Frost Ring, Stone Ring, Leather Gloves, Iron Helm, and Combo Lens.
  - Acceptance: Each common item has a working effect, price, icon or placeholder icon, and shop description.

- [x] Implement uncommon equipment.
  - Deliverable: Twin Blades, War Banner, Tower Shield, Merchant Scales, Battle Drum, Earthbreaker Maul, Hearth Amulet, Alchemist Gloves, Training Manual, and Mirror Charm.
  - Acceptance: Each uncommon item has a working effect, price, icon or placeholder icon, and shop description.

- [x] Implement rare equipment.
  - Deliverable: Ruby Brooch, Sapphire Brooch, Emerald Brooch, Royal Seal, and Champion Plate.
  - Acceptance: Each rare item has a working effect, price, icon or placeholder icon, and shop description.

- [x] Implement 5 relics.
  - Deliverable: Deep Pockets, Stalwart Mantle, Golden Idol, Crown of Chains, and Merchant Compass.
  - Acceptance: Each relic modifies the run for the rest of the run and displays clearly in the relic inventory.

- [x] Implement at least 3 normal enemies.
  - Deliverable: Striker, Defender, and Charger or equivalent enemies based on the GDD pattern table.
  - Acceptance: Each enemy has HP, readable intent cycle, attack values, block values, and level scaling.

- [x] Implement at least 3 bosses.
  - Deliverable: Three boss checks chosen from Iron Gate, Burning Knight, Prism Warden, Combo Gate, and Rising Blade.
  - Acceptance: Each boss has a previewed identity, readable moveset, and a distinct build or execution pressure.

- [x] Implement content pool rules.
  - Deliverable: Shop and booster pools by rarity, category, orb type, and current dungeon level.
  - Acceptance: Random generation produces valid content and avoids duplicates where the GDD requires no duplicates.

Verification notes (2026-04-27):
- Replaced debug-only content definitions with full Milestone 8 pack in `scripts/content/content_registry.gd`:
  - 10 common, 10 uncommon, and 5 rare equipment items.
  - 5 relics, plus existing 6 mastery cards and 6 consumables.
  - 3 normal enemies and 3 bosses represented in content data.
- Added item/relic `combat_modifiers` and integrated them into turn resolution via `RunState.current_combat_modifiers()` and `CombatStateMachine`.
- Added content pool level gating (`min_level`, `max_level`) for shop/relic generation and maintained no-duplicate offer selection.
- Added placeholder content presentation fields (`description`, `icon_key`) and surfaced item description text in shop offer buttons.
- Milestone 8 QA execution completed via Godot MCP editor-script checks: mastery/consumable resolution paths, equipment buy/equip/sell/resolve flows, relic buy/resolve flows, enemy/boss run-sequence coverage, and shop/booster pool-rule checks all passed with no reported failures.

## Milestone 9: UI, UX, And Game Feel

Status: In progress.

Goal: Make the prototype readable, playable, and comfortable enough for repeated playtesting.

Primary deliverable: A cohesive game flow where combat, shop, inventory, item effects, enemy intent, and run progress are understandable without debug tools.

Tasks:

- [x] Implement combat HUD.
  - Deliverable: Player HP, armor, gold, move timer, enemy HP, enemy block, enemy intent, combo count, and recent result summary.
  - Acceptance: The player can understand the current turn at a glance.

- [x] Implement inventory UI.
  - Deliverable: Equipment slots, consumable slots, relic list, and mastery levels.
  - Acceptance: The player can inspect current build state during combat and shop, including owned relics in the shared footer HUD.

- [x] Implement item detail views.
  - Deliverable: Tooltip or detail panel for equipment, mastery cards, consumables, relics, and boosters.
  - Acceptance: Item effect text is visible before buying, using, or selling.

- [x] Implement shop UI.
  - Deliverable: Shop offers, prices, buy buttons, reroll, sell controls, booster opening view, and skip shop.
  - Acceptance: The player can complete all shop actions without debug input.

- [x] Implement boss and dungeon UI.
  - Deliverable: Level number, upcoming boss preview, current sequence step, and transition screens.
  - Acceptance: The player knows where they are in the run and what threat is coming.

- [x] Add feedback for match resolution.
  - Deliverable: Clear, fall, refill, cascade, combo, damage, heal, armor, and gold feedback.
  - Acceptance: The player can connect board results to combat outcomes.

- [~] Add basic audio and visual polish.
  - Deliverable: Placeholder sound effects, hit feedback, item purchase feedback, enemy death feedback, and simple transitions.
  - Acceptance: Important actions produce readable response without slowing play.
  - Note: 2026-05-02 added a code-generated placeholder audio manager, scene music contexts, and SFX hooks for menu start, combat drag swaps, combat match/combo/result/victory/defeat, and shop purchase/reroll/sell/booster actions. Raw MIDI files now export through FluidSynth and `raw/GeneralUser GS v1.471.sf2` into normalized signed 16-bit WAVs in `resources/audio/music/`, and `AudioManager` prefers those WAV music assets when present. The main menu owns a direct `MainMenuMusicPlayer` for `main-menu.wav`, while `AudioManager` now opens the absolute source WAV for combat/shop music before falling back to Godot imports; both paths decode PCM into memory and play at `-12 dB`. Manual listening, mix, and loop-point review remains needed before marking complete.
  - Note: 2026-05-03 Android export audio hardening now prefers imported `res://` audio streams in template/export builds before direct source-WAV decoding, while keeping generated SFX active. Godot MCP confirmed imported combat/menu WAV streams load as `AudioStreamWAV`, generated `swap` SFX builds, combat music logs from `AudioManager`, and main menu music logs from `MainMenuMusicPlayer`; Android on-device listening remains needed.
  - Note: 2026-05-03 Android audio regression follow-up routes menu music through `AudioManager`, tries uploaded WAV/imported music first for menu/combat/shop on Android/template builds, configures imported WAV loop bounds, and keeps generated music as fallback only. Android on-device listening still needs confirmation.

- [~] Validate responsive layout.
  - Deliverable: Desktop and mobile aspect ratio checks for board, combat HUD, shop, and inventories.
  - Acceptance: Text and controls do not overlap on target resolutions.
  - Note: 2026-05-03 combat now uses tall-portrait design height when the viewport is narrower/taller than 1080x1920, so extra Android height expands the board zone before extending the player HUD. The default 1080x1920 board remains 480x576, while a 1080x2400 probe computes an 880x1056 board with no design-space gap between board/HUD and the bottom of the root. Real Android visual review remains needed before marking mobile overlap complete.
  - Note: 2026-05-03 Android combat touch regression follow-up fixed the scaled-board touch path by using `BoardView.gui_input` local touch positions directly; Android on-device touch selection retest remains needed.

Verification notes (2026-04-27):
- Promoted combat screen from debug-style readout to Milestone 9 HUD with explicit run progress, turn summary, combo summary, and readability-focused status feedback.
- Extended shop and boss-reward scenes with run progress, inventory/mastery visibility, and inline effect/detail text so purchase and reward decisions are readable without console commands.
- Added responsive compact-mode handling in combat HUD spacing/min-width logic; full mobile overlap verification remains pending on-device.
- Godot MCP validation passed for updated scene load/instantiation checks and main-scene run smoke test with no reported session errors.
- Added Milestone 9 responsive layout hardening for combat/shop surfaces:
  - `BoardAndStateRow`, `ShopActionsRow`, and `BottomActionsRow` now use adaptive `BoxContainer` layout switching (horizontal desktop, vertical compact/mobile).
  - Combat status/state labels now use autowrap to reduce clipping risk in narrow layouts.
- Godot MCP post-change checks passed for script parse state, `res://scenes/main.tscn` run smoke, and shop scene load/instantiate.
- 2026-05-02 dungeon playthrough fix: shared `PlayerLoadoutHud` footer now includes owned relics for combat and shop, with compact icon overflow for tight space.
- 2026-05-02 shop generation follow-up: shop stock and booster equipment options filter out already-equipped equipment, consumables can be sold from a unified non-clipped inventory popover, owned relics sit between the HP panel and the equipment/consumable rows, and the popover dismisses when inventory focus is lost.
- Milestone 9 graphical asset integration pass (combat + shop) is now wired through a dedicated visual registry and player-facing scenes:
  - Added `scripts/ui/visual_registry.gd` and `resources/visual/first_pass_asset_map.json` as the centralized texture lookup/mapping contract (backgrounds, enemy portraits, orb/intent/rarity/mastery/item atlases, and VFX sheet hooks with fallbacks).
  - Added player-facing scene routes:
	- Combat: `res://scenes/combat/combat_player.tscn` (controller: `res://scripts/combat/combat_player_controller.gd`)
	- Shop: `res://scenes/flow/shop_player.tscn` (controller: `res://scripts/flow/shop_player.gd`)
  - `RunState` transition constants route fights and shops to the player-facing scenes.
  - `BoardView` now supports orb atlas rendering (`orb_id -> Texture2D`) with color fallback and preserves selection/path/flash/glow/fall/refill behavior.
  - First-pass art assets were reorganized under `res://resources/art/first_pass/{backgrounds,enemies,sheets,ui,vfx}` with per-class mipmap policy in `.import` files (`backgrounds/enemies: true`, UI sheets: false).
  - Added lightweight VFX hooks driven by combat events:
	- enemy damage -> hit flash,
	- resolver clear -> orb clear burst,
	- gold gain -> sparkle.
  - Added shared theme resource `res://resources/visual/first_pass_theme.tres` and applied it to player-facing combat/shop scenes.
  - Godot MCP validation passed for scene instantiate and runtime smoke on:
	- `res://scenes/combat/combat_player.tscn`
	- `res://scenes/flow/shop_player.tscn`
	- `res://scenes/main.tscn`
- Reference player-panel revamp added for `res://scenes/combat/combat_player.tscn`:
  - Rebuilt the bottom player HUD into a reference-style hero portrait card, primary HP bar, compact equipment/consumable rails, and bottom mastery strip.
  - Armor, stat chip, combat meta, and turn summary rows stay hidden so the simplified HUD does not show empty placeholder bars or clutter.
  - Godot MCP load/instantiate and running scene-tree checks passed for the reference-aligned player-panel structure at the current portrait design size.

## Architecture Maintenance: Review Task Tracking Plan

Status: In progress.

Goal: Track architecture-refactor risks and regression harness follow-up before Milestone 10 balance closure.

Tracker: `docs/architecture_review_tasks.md`

Tasks:

- [x] AR-01 Baseline regression harness.
- [x] AR-02 Low-risk bug fixes.
- [x] AR-03 Shared WAV/audio utility extraction.
- [x] AR-04 Shop/input safety.
- [x] AR-05 Combat controller first split.
- [x] AR-06 Combat presentation split.
- [x] AR-07 RunState/data contract roadmap. Prototype content source of truth is dictionary-backed `ContentRegistry` data for this phase; `.tres` or JSON migration is deferred behind the registry API.
- [x] AR-08 Cleanup/dead-code validation. Removed confirmed-unused code symbols/helpers, renamed the final victory summary to `final_run_summary`, removed the legacy boss relic reward scene, removed the legacy shop placeholder scene, and removed the board-debug scene/controller. Current validation now uses player-facing scenes plus focused Godot MCP probes instead of the deleted debug/fallback surfaces.
- [x] AR-09 Stability and shared UI utility cleanup. Added lifecycle guards, bounded resolve animation drain, traced combat redirect, Start Run failure recovery, final-summary transition guards, and shared `UiUtils.panel_style(...)` ownership.
- [x] AR-10 Combat controller god-object refactor. Extracted `CombatDebugConsole` and `CombatTurnLogger` while keeping privileged gameplay callbacks, `/skip`, routing, input, layout, VFX timing, and combat state in the controller.
- [x] AR-11 Combat layout manager extraction. Extracted combat scene geometry and responsive layout ownership into `CombatLayoutManager` while preserving portrait/tall viewport behavior and shared HUD layout overrides.
- [x] AR-12 Combat VFX manager extraction. Extracted transient combat VFX drawing mechanics into `CombatVfxManager` while keeping replay order, combat math, mastery feedback semantics, routing, input, layout, audio, debug callbacks, and `/skip` in the controller.
- [x] AR-13 Board drag input handler extraction. Extracted board-local drag/pointer bookkeeping into `BoardDragInputHandler` while preserving `BoardView.gui_input` local-coordinate behavior, current drag rules, swap feel, resolve kickoff, combat math, timing, routing, layout, VFX, audio callback policy, debug callbacks, and `/skip` ownership in the controller.
- [x] AR-14 Combat theme and chrome boundary. Extracted combat style/chrome construction into `CombatChromeStyler` while preserving existing colors, borders, radii, margins, font sizes, timer runtime behavior, placeholders, layout formulas, input, VFX, combat math, resolve presentation, route transitions, `UiUtils.panel_style(...)`, and `/skip` ownership.
- [x] AR-15 Combat placeholder texture utility. Extracted timer, intent, enemy portrait, and hero portrait code-generated placeholder texture builders into `CombatPlaceholderTextures` while preserving dimensions, colors, alpha, fill rectangles, fallback decisions, VisualRegistry lookup behavior, assignment timing, layout, chrome, combat math, route transitions, and `/skip` ownership.
- [x] AR-16 Combat HUD sync boundary review. Extracted side-effect-free combat HUD snapshot construction into `CombatHudSnapshotBuilder` while keeping scene-specific label/bar/node application, `PlayerLoadoutHud` payload dispatch, loadout rail layout refresh, placeholder fallback assignment, combat-only enemy/timer/status behavior, shop HUD behavior, mastery feedback/card rendering, combat math, route transitions, and `/skip` ownership unchanged.
- [x] AR-17 Combat outcome and transition boundary review. Source review found a narrow behavior-preserving transition glue boundary inside `combat_player_controller.gd`; `_trace_and_change_scene_to_target(...)` now owns duplicated combat outcome trace/change-scene calls for standard Continue, boss reward claim, and boss reward skip while `RunState` keeps route semantics and `CombatOutcomeOverlay` keeps presentation. Automated Godot MCP validation passed, and user manual QA found no issues or errors.
- [x] AR-18 Architecture review closeout before Milestone 10. Audited the final AR tracker state, current validation surfaces, deleted historical debug/fallback scenes, retained diagnostics, docs/wiki consistency, route/content/scene contracts, and remaining non-AR QA gaps. AR-01 through AR-17 are closed; remaining work moves to Milestone 10 balance/QA or later scoped cleanup.

## Milestone 10: Short-Term Playtest Balance Pass

Status: In progress.

Goal: Make the current run loop easier to playtest before adding meta progression.

Primary deliverable: A temporary balance layer where gold income, shop access, damage, enemy survivability, and debug levers let the team repeatedly test items, boosters, relics, and builds without pretending the economy is final.

Scope note: This milestone is a playtest-enabling pass, not the final balance pass. Meta progression will change power curves, unlock pacing, and economy pressure, so deep final tuning should happen after meta progression exists.

Tracker: `docs/milestone_10_balance_tasks.md`

Execution note: M10 work should proceed through the tracker order: add the Run Log and active balance-source inventory, capture untuned baseline logs, add temporary balance levers, tune economy and survivability, improve content test access, then close out with focused playtest evidence. Do not tune balance values before baseline evidence exists.

Tasks:

- [x] Add run-log baseline evidence capture.
  - Deliverable: Passive Run Log with opt-in JSON/text/Markdown file generation under gitignored `logs/` plus an inventory of active balance data owners.
  - Acceptance: M10-01 identifies orb weights, run gold, combat formulas, shop pricing, active encounter stats, debug commands, and current validation surfaces before tuning. Runtime logging records run, fight, turn, shop, boss reward, and run-end events without changing combat math, shop behavior, route semantics, balance values, or presentation timing.
  - Note: 2026-05-05 M10-01 added `RunState.run_log_snapshot()`, `run_log_export_json(...)`, `run_log_export_text()`, `run_log_export_markdown()`, and a main-menu `Generate Log` toggle for per-run export to `logs/` on run end. Focused Godot MCP probes verified representative events and generated files; normal untuned baseline playthroughs were completed in M10-02.

- [x] Capture untuned baseline runs.
  - Deliverable: At least 3 human-played untuned Run Logs from normal `Start Run` playthroughs, not automated probes, `/skip`, forced outcomes, debug-command runs, or simulated editor runs.
  - Acceptance: M10-02 records level/fight reach, turns per fight, gold, shop access, purchases, deaths, item/relic access, and blocker categories before any balance tuning.
  - Note: 2026-05-05 M10-02 verified 3 human-played baseline logs. The runs covered a high-skill defeat at level 2 boss, an intentional new-player simulation defeat in level 1 fight 1, and a third defeat at level 3 enemy 1. Current blockers are mixed: first-shop affordability, first-fight survivability/combat effectiveness, and level 2-3 enemy pressure.

- [ ] Add or expose playtest balance levers.
  - Deliverable: Configurable values for gold income, starting gold, shop affordability, enemy HP/damage scaling, or equivalent debug/test settings.
  - Acceptance: Designers can make item and shop testing easier without rewriting core systems.

- [ ] Tune early gold access.
  - Deliverable: Temporary prototype settings for gold orb value/spawn rate, starting gold, fight rewards, shop prices, or booster affordability.
  - Acceptance: After the first enemy, a normal playtest run can usually buy at least one item, booster, consumable, or useful shop option.

- [ ] Tune early combat survivability.
  - Deliverable: Temporary level 1-2 enemy HP, damage, block, and player starting-stat adjustments.
  - Acceptance: Runs survive long enough to reach multiple shops and test build decisions, while mistakes can still matter.

- [x] Tune item and relic test access.
  - Deliverable: Temporary economy or debug flow that makes equipment, mastery cards, consumables, relics, and boosters practical to inspect during repeated runs.
  - Acceptance: A tester can exercise most implemented content without needing many failed economy-starved runs.
  - Note: 2026-05-05 M10-06 retuned shop access after the first evidence pass: shops now guarantee at least one booster when available, bias remaining offers toward equipment, keep mastery cards possible, make consumables rare, and avoid a second booster unless needed. The first level-1 shop now guarantees affordable damage equipment (`Shortsword`) instead of `Coin Purse`; `Shortsword` price is `10`. Shop relic offers now persist as one relic per level, showing sold-out in later same-level shops after purchase and refreshing only on the next dungeon level. Merchant Compass free-first-reroll remains deferred.

- [ ] Record first-pass balance assumptions.
  - Deliverable: Short notes in `docs/test_plan.md` or relevant wiki pages describing temporary balance values, what they are meant to test, and what is intentionally not final.
  - Acceptance: Future meta progression work can distinguish test scaffolding from accepted design.

- [ ] Run focused playtest loops.
  - Deliverable: Recorded notes from repeated level 1 and early-run playtests covering gold earned, shop purchases, deaths, item access, and major blockers.
  - Acceptance: The team has enough evidence to start meta progression on a playable baseline.

## Milestone 11: Meta Progression Foundation

Status: Not started.

Goal: Add a mastery/meta layer that gives long-term structure to repeated runs after the core loop is easier to playtest.

Primary deliverable: A first meta progression system that can support equipment unlocks, mastery growth, or other persistent goals without hiding core-loop balance problems.

Tasks:

- [ ] Define meta progression scope.
  - Deliverable: Selected first meta system, such as equipment unlocks, mastery progression, account upgrades, hero growth, or content pool expansion.
  - Acceptance: The system has a clear player-facing purpose and does not duplicate existing run-only mastery cards.

- [ ] Define persistence model.
  - Deliverable: Runtime state shape for meta progress, unlock flags, earned currency or XP, and reset/new-run behavior.
  - Acceptance: Meta data can persist across runs separately from temporary `RunState` data.

- [ ] Implement first unlock/progression loop.
  - Deliverable: A small playable vertical slice where completing fights, bosses, runs, or challenges advances meta progress and changes future run options.
  - Acceptance: The player has a reason to start another run beyond one-run victory or defeat.

- [ ] Connect meta progression to content access.
  - Deliverable: Equipment, relic, mastery, consumable, hero, or dungeon content can be gated or expanded by meta state.
  - Acceptance: Unlocks affect future runs in an understandable way without breaking current shop/combat flows.

- [ ] Validate meta progression with the temporary balance layer.
  - Deliverable: Playtest notes showing how meta progress changes run difficulty, item access, and economy pressure.
  - Acceptance: Remaining balance work is documented as post-meta tuning rather than mixed with initial system implementation.

## Milestone 12: First Playable Build

Goal: Package and document the first playable prototype.

Primary deliverable: A playable build that demonstrates the full GDD vertical slice and can be shared for feedback.

Tasks:

- [ ] Add export presets.
  - Deliverable: Export configuration for PC, with mobile export prepared if certificates and SDKs are available.
  - Acceptance: A clean build can be produced from the project without manual scene changes.

- [ ] Build release candidate.
  - Deliverable: First playable build artifact.
  - Acceptance: Build launches, starts a run, completes fights and shops, and reaches victory or defeat.

- [ ] Write player-facing notes.
  - Deliverable: Short prototype notes covering controls, current scope, known limitations, and feedback focus.
  - Acceptance: A tester can play without reading the GDD.

- [ ] Write developer handoff notes.
  - Deliverable: Notes describing architecture, content creation flow, test checklist, and major known risks.
  - Acceptance: Future contributors can add content or tune balance without reverse engineering the prototype.

- [ ] Tag first playable scope.
  - Deliverable: Git tag or milestone marker once the build is accepted.
  - Acceptance: The first playable state can be retrieved and compared against later iterations.

## Cross-Cutting Technical Tasks

These tasks should be worked on alongside the milestones when the affected systems appear.

- [ ] Deterministic RNG support.
  - Deliverable: Seeded RNG for board generation, shops, boosters, and enemy selection.
  - Acceptance: A run can be reproduced for debugging.

- [ ] Save-safe run state shape.
  - Deliverable: Run state that can later be serialized even if saving is not included in the prototype.
  - Acceptance: State objects avoid direct scene-node dependencies.

- [ ] Debug tools.
  - Deliverable: Debug commands for win fight, lose fight, add gold, add item, spawn enemy, set board, and jump to shop.
  - Acceptance: Designers can test systems without playing a full run every time.

- [ ] Error reporting.
  - Deliverable: Clear debug logs or UI warnings for invalid content data and impossible states.
  - Acceptance: Runtime issues are diagnosable from logs.

- [ ] Automated logic tests where practical.
  - Deliverable: Tests for board generation, matching, cascades, scoring, item effects, and shop generation.
  - Acceptance: Core deterministic systems can be checked without manual play.

## Open Design Decisions To Resolve During Implementation

- [ ] Exact gold orb spawn rate.
  - Deliverable: Prototype spawn weight setting.
  - Decision point: Resolve during Milestone 10 after shop and economy are playable.

- [ ] Exact shop price ranges by rarity and dungeon level.
  - Deliverable: Prototype price table.
  - Decision point: Resolve during Milestones 6 and 10.

- [ ] Reroll cost curve.
  - Deliverable: Reroll cost formula and Merchant Compass behavior.
  - Decision point: Resolve during Milestone 6.

- [ ] Boss roster for the 3-level prototype.
  - Deliverable: Selected 3 bosses from the GDD boss direction list.
  - Decision point: Resolve before Milestone 8 content implementation.

- [ ] Whether L and T matches get bonus effects.
  - Deliverable: Prototype decision.
  - Decision point: Default to no bonus beyond matched orb count unless playtesting shows the board needs more reward clarity.

- [ ] Whether 5 seconds is right for both PC and mobile.
  - Deliverable: Prototype movement timer setting.
  - Decision point: Keep 5 seconds for first playable, then tune after mobile input testing.

## Recommended Immediate Next Steps

1. Create the folder structure and main debug scene from Milestone 0.
2. Implement `BoardState` and orb definitions from Milestone 1.
3. Build the board renderer and deterministic no-starting-match generator.
4. Implement mouse/touch drag movement before adding combat.
5. Add match resolver tests before connecting cascades to scoring.

## First Playable Definition Of Done

The prototype is considered first playable when:

- A new run can be started from the game.
- The player can complete or lose a 3-level dungeon run.
- All six orb types appear and resolve correctly.
- Free movement, timer, matching, and cascades work according to the GDD.
- Enemy intent is shown before movement and resolves after player effects.
- HP, armor, gold, equipment, mastery, consumables, and relics persist correctly across the run.
- Shops appear after fights and support buying, selling, rerolling, boosters, relic offers, and skipping.
- Bosses provide clear checks and grant relic rewards.
- The initial content pack is present and functional.
- The build can be exported and played without debug tools.
