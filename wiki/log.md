# Wiki Log

Append-only history of wiki operations.

## [2026-04-28] ingest | Initial Project Ingestion

- Source: `AGENTS.md`, `project.godot`, `todo.md`, `docs/system_architecture.md`, `docs/test_plan.md`, `docs/game_design_document.md`, `scripts/core/run_state.gd`, `scripts/content/content_registry.gd`, `scripts/combat/combat_state_machine.gd`, `scripts/shop/shop_service.gd`, `scripts/run/player_progression_state.gd`, `scripts/run/player_progression_service.gd`, `scripts/board/board_state.gd`, `scripts/board/board_view.gd`, `scripts/flow/shop_player.gd`, `scripts/flow/boss_relic_reward.gd`, `scripts/core/main_boot.gd`, `scripts/debug/board_debug_controller.gd`
- Changed:
  - Created `wiki/index.md`
  - Created `wiki/log.md`
  - Created `wiki/setup.md`
  - Created `wiki/architecture.md`
  - Created `wiki/file-map.md`
  - Created `wiki/features.md`
  - Created `wiki/decisions.md`
  - Created `wiki/known-issues.md`
  - Created `wiki/open-questions.md`
  - Created `raw/`
- Notes:
  - The live code currently uses a dictionary-backed `ContentRegistry`, while `docs/system_architecture.md` still describes a planned Resource-based content model. That mismatch is recorded in the wiki.

## [2026-04-28] docs | Milestone 9 Combat UI Replication Plan

- Source: `todo.md`, `docs/test_plan.md`, `scenes/combat/combat_player.tscn`, `scripts/combat/combat_player_controller.gd`, `scripts/ui/visual_registry.gd`, `C:/Users/Home/Desktop/combat-ref.png`
- Changed:
  - Created `wiki/milestone-9-combat-ui-replication-plan.md`
  - Updated `wiki/index.md`
- Notes:
  - Plan captures approved constraints: close-match fidelity, combat-only scope, and no new mana system.

## [2026-04-28] code-change | Milestone 9 Combat HUD Close-Match Pass

- Source: `scenes/combat/combat_player.tscn`, `scripts/combat/combat_player_controller.gd`, `scripts/ui/visual_registry.gd`, `docs/test_plan.md`, `C:/Users/Home/Desktop/combat-ref.png`
- Changed:
  - Updated `scripts/combat/combat_player_controller.gd`
  - Updated `scenes/combat/combat_player.tscn`
  - Updated `wiki/features.md`
- Notes:
  - Implemented combat-only close-match UI pass using existing visual assets and runtime data bindings.
  - No new mana system was introduced; secondary blue bar remains presentation for existing armor flow.

## [2026-04-28] code-change | Combat Scene Reset To Board-Only Baseline

- Source: `scenes/combat/combat_player.tscn`, `scripts/combat/combat_board_only_controller.gd`
- Changed:
  - Created `scripts/combat/combat_board_only_controller.gd`
  - Replaced `scenes/combat/combat_player.tscn` with board-only scene structure
  - Updated `wiki/features.md`
- Notes:
  - Removed all combat HUD sections to start Milestone 9 HUD revamp from a clean baseline while preserving only the board surface.

## [2026-04-28] code-change | Restore Combat Functionality With Plain Visual Baseline

- Source: `scenes/combat/combat_player.tscn`, `scripts/combat/combat_player_controller.gd`
- Changed:
  - Restored full combat scene functionality wiring in `scenes/combat/combat_player.tscn`
  - Updated `scripts/combat/combat_player_controller.gd` to plain-visual mode (no background art, no enemy portrait, no intent badge texture)
  - Removed temporary `scripts/combat/combat_board_only_controller.gd`
  - Updated `wiki/features.md`
- Notes:
  - Keeps gameplay and HUD behavior intact while stripping most art-heavy presentation for rebuild.

## [2026-04-28] code-change | Orb Sprite Cleanup For Board Rendering

- Source: `scripts/ui/visual_registry.gd`
- Changed:
  - Updated orb extraction cleanup to keep only the primary connected orb component after checker-noise removal.
- Notes:
  - Reduced visual glitch fragments on non-earth orb sprites while keeping the same orb texture source pipeline.

## [2026-04-28] code-change | Extract Reusable Board Surface From Combat UI

- Source: `scenes/combat/combat_player.tscn`, `scenes/board/board_surface.tscn`, `scripts/combat/combat_player_controller.gd`, `scripts/board/board_surface.gd`
- Changed:
  - Created `scenes/board/board_surface.tscn`
  - Created `scripts/board/board_surface.gd`
  - Updated `scenes/combat/combat_player.tscn` to instance `BoardSurface`
  - Updated `scripts/combat/combat_player_controller.gd` to bind through `BoardSurface`
  - Updated `wiki/file-map.md`
- Notes:
  - Refactor keeps combat behavior intact while separating board composition from combat-specific scene layout.

## [2026-04-28] code-change | Portrait Mobile Viewport And Combat HUD Layout Pass

- Source: `project.godot`, `scenes/combat/combat_player.tscn`, `scripts/combat/combat_player_controller.gd`, `C:/Users/Home/Desktop/combat-ref.png`
- Changed:
  - Updated `project.godot` to portrait viewport `1080x1920`
  - Updated `scenes/combat/combat_player.tscn` to show combat HUD sections by default and tune panel sizing/margins
  - Updated `scripts/combat/combat_player_controller.gd` responsive breakpoints and portrait sizing targets
  - Updated `wiki/features.md`
- Notes:
  - This pass focuses on matching overall mobile composition from the provided reference while keeping current runtime bindings and placeholder visuals.

## [2026-04-28] code-change | Combat HUD Visual Polish Pass

- Source: `scenes/combat/combat_player.tscn`, `scripts/combat/combat_player_controller.gd`, `C:/Users/Home/Desktop/combat-ref.png`
- Changed:
  - Updated `scripts/combat/combat_player_controller.gd` for stronger panel/bar/button styling and typography hierarchy
  - Updated `scenes/combat/combat_player.tscn` section sizing and spacing for improved portrait composition
  - Updated `wiki/features.md`
- Notes:
  - Kept gameplay logic and data bindings unchanged; this pass is presentation-only polish for readability and reference alignment.

## [2026-04-28] code-change | Zone Refactor And Placeholder Blocks For Missing Combat Art

- Source: `scenes/combat/combat_player.tscn`, `scripts/combat/combat_player_controller.gd`, `C:/Users/Home/Desktop/combat-ref.png`
- Changed:
  - Updated `scenes/combat/combat_player.tscn` to tighten section spacing and make `BoardArea` explicit for zone sizing
  - Updated `scripts/combat/combat_player_controller.gd` with centralized zone-height profile (`_apply_zone_profile`)
  - Added persistent placeholder textures for missing intent/enemy/hero art slots
  - Updated `wiki/features.md`
- Notes:
  - Refactor is aimed at faster visual iteration and clearer zone-by-zone tuning without touching combat logic.

## [2026-04-28] code-change | Promote Combat Zones To First-Class Scene Nodes

- Source: `scenes/combat/combat_player.tscn`, `scripts/combat/combat_player_controller.gd`
- Changed:
  - Renamed and normalized major sections to explicit zone nodes: `TopBar`, `EnemyPanel`, `CombatStrip`, `BoardPanel`, `PlayerPanel`
  - Updated controller bindings and style/size logic to target the new zone names
  - Updated `wiki/features.md`
- Notes:
  - This is a structural readability refactor for faster polish iteration; no combat behavior changes.

## [2026-04-28] code-change | Full Zone Polish Refactor With Placeholders And Guides

- Source: `scenes/combat/combat_player.tscn`, `scripts/combat/combat_player_controller.gd`, `C:/Users/Home/Desktop/combat-ref.png`
- Changed:
  - Tightened major zone spacing and heights to reduce dead space (`EnemyPanel`, `CombatStrip`, `BoardPanel`, `PlayerPanel`)
  - Refactored player internals into explicit subzones: `PlayerStatsRow`, `CombatMetaRow`, `LoadoutRow`
  - Added stable placeholders for missing intent/enemy/hero visuals with preserved layout footprint
  - Added toggleable zone guide labels/outlines on `F2` for polish iteration
  - Updated `wiki/features.md`
- Notes:
  - Focused on presentation architecture and polish workflow; core combat logic remains unchanged.

## [2026-04-28] code-change | Final Mobile Combat Polish Consolidation

- Source: `scenes/combat/combat_player.tscn`, `scripts/combat/combat_player_controller.gd`, `C:/Users/Home/Desktop/combat-ref.png`
- Changed:
  - Reduced remaining dead space and rebalanced zone proportions for mobile portrait
  - Consolidated layout/typography tuning into shared controller constants
  - Stabilized combo block width and right alignment in combat strip
  - Simplified player metadata line formatting and constrained summary verbosity
  - Kept placeholder-driven enemy/intent/hero footprints active for continued artless polish
  - Updated `wiki/features.md`
- Notes:
  - Intended as a full implementation of the requested polish checklist while keeping gameplay behavior unchanged.

## [2026-04-29] code-change | Combat Screen Design-Space Layout Rebuild

- Source: `scenes/combat/combat_player.tscn`, `scripts/combat/combat_player_controller.gd`, `C:/Users/Home/Desktop/combat-ref.png`
- Changed:
  - Replaced vertical combat HUD layout with `CombatLayoutRoot` and direct design-space rect positioning
  - Added `_apply_combat_layout()` for scaled `1080x1920` zone placement
  - Rebuilt enemy, combat strip, board, and player panel composition around explicit subzones
  - Added generated placeholder helper methods for intent, enemy, and hero art footprints
  - Updated `wiki/features.md`
- Notes:
  - Validated scene instantiation and current-scene runtime through Godot MCP with no reported runtime errors.

## [2026-04-29] code-change | Timer-Only Strip And Loadout Group Polish

- Source: `scenes/combat/combat_player.tscn`, `scripts/combat/combat_player_controller.gd`, `C:/Users/Home/Desktop/combat-ref.png`
- Changed:
  - Removed combat strip combo/damage label and rebuilt timer lane with `TimerBadgePanel` icon+value plus single timer bar
  - Added timer placeholder generation and timer badge styling in combat controller
  - Rebuilt player loadout to centered framed groups: `EquipmentGroup` (5 slots) and `ConsumableGroup` (3 slots)
  - Updated slot rendering to 64px with darker empty placeholders and consumable count overlays
  - Updated `wiki/features.md` and `wiki/file-map.md`
- Notes:
  - Runtime validated via Godot MCP (`open_scene`, `play_scene`, `get_running_scene_screenshot`, `get_godot_errors`) with no active runtime errors.

## [2026-04-29] code-change | Combat Timer Urgency Readability Revamp

- Source: `scripts/combat/combat_player_controller.gd`, `scenes/combat/combat_player.tscn`
- Changed:
  - Updated timer formatting to show whole seconds in normal state and tenth-second precision during final warning window
  - Added timer urgency color states (`safe`, `warning`, `critical`) and applied them to both timer label and timer bar fill
  - Added critical low-time pulse behavior for better timeout visibility during drag
  - Updated `wiki/features.md`
- Notes:
  - Timer duration and move-end rules remain unchanged; this pass is readability and urgency signaling only.

## [2026-04-29] code-change | Combat Strip Timer Centering Fix

- Source: `scripts/combat/combat_player_controller.gd`
- Changed:
  - Centered the timer strip based on actual content width (`TimerBadgePanel + separator + MoveTimerBar`) instead of left-inset anchoring
  - Added responsive timer-bar width clamp so centering stays stable across viewport sizes
- Notes:
  - No timer logic changes; this is layout-only.

## [2026-04-29] code-change | Unified Combat Timer Track Revamp

- Source: `scenes/combat/combat_player.tscn`, `scripts/combat/combat_player_controller.gd`
- Changed:
  - Replaced the separate timer badge and progress bar with one centered `TimerTrack` control
  - Added track fill, overlay icon/value/state labels, and unified timer display syncing
  - Kept the 5 second movement timer, release behavior, and timeout behavior unchanged
  - Updated `wiki/features.md`
- Notes:
  - This replaces the previous centering workaround with a single fixed design-space timer slab.

## [2026-04-29] code-change | Timer Label Readability Fix

- Source: `scripts/combat/combat_player_controller.gd`
- Changed:
  - Separated timer foreground colors from timer fill colors for higher contrast
  - Added label outline and shadow styling to timer value and state labels
- Notes:
  - No timer logic or layout changes.

## [2026-04-29] code-change | Reference Player Panel Revamp

- Source: `scenes/combat/combat_player.tscn`, `scripts/combat/combat_player_controller.gd`, `C:/Users/Home/Desktop/combat-ref.png`
- Changed:
  - Rebuilt the combat player panel around reference-style bottom HUD zones: hero card, HP/armor vitals, stat chips, compact loadout rail, and mastery strip
  - Replaced large equipment/consumable boxes with fixed manual slot rails for 5 equipment and 3 consumables
  - Added equipment value badges, consumable count badges, dim empty-slot placeholders, and always-visible mastery levels
  - Updated `docs/test_plan.md`, `wiki/features.md`, and `wiki/file-map.md`
- Notes:
  - Godot MCP load/instantiate and running scene-tree checks passed for the new player-panel node structure and current portrait layout bounds.

## [2026-04-29] code-change | Compact Player Panel Cleanup

- Source: `scripts/combat/combat_player_controller.gd`, `docs/test_plan.md`, `wiki/features.md`
- Changed:
  - Hid the cramped armor bar, stat chip row, and turn summary text from the compact combat player panel
  - Moved the equipment/consumable rail and mastery strip upward with larger vertical spacing
  - Updated documentation to record the simplified compact player-panel presentation
- Notes:
  - Godot MCP runtime scene-tree inspection confirmed the cleaned player panel sections are visible and bounded in the current design-space layout.

## [2026-04-29] code-change | Player Panel Spacing Tightening

- Source: `scripts/combat/combat_player_controller.gd`, `docs/test_plan.md`
- Changed:
  - Reduced the hero card and portrait footprint
  - Pulled the equipment/consumable rail closer to the HP row
  - Compressed the mastery strip to remove unused vertical space
- Notes:
  - Godot MCP runtime scene-tree inspection confirmed the tightened player panel layout positions and bounds.

## [2026-04-29] code-change | Player Panel Frame Collapse

- Source: `scripts/combat/combat_player_controller.gd`, `scenes/combat/combat_player.tscn`, `docs/test_plan.md`, `todo.md`, `wiki/features.md`
- Changed:
  - Shortened the active player panel frame to the compact HUD content height
  - Kept the hero, HP, loadout, and mastery rows in fixed design-space positions
  - Converted `MasteryStrip` from `PanelContainer` to `Panel` so the compact mastery frame does not expand from child minimum sizing
  - Grouped mastery icons beside the `MASTERY` label and kept hidden legacy rows out of the visible panel
- Notes:
  - Godot MCP play-scene, runtime scene-tree, and error-log checks passed for the compact player panel bounds.

## [2026-04-29] code-change | Player Panel Reference Correction

- Source: `scripts/combat/combat_player_controller.gd`, `docs/test_plan.md`, `todo.md`, `wiki/features.md`
- Changed:
  - Restored the reference bottom-HUD proportions after the previous compact pass diverged too far
  - Enlarged the hero portrait card while keeping only the primary HP bar visible
  - Moved the equipment/consumable rail under the vitals block with larger slots and restored a full-width bottom mastery strip
  - Changed mastery entries from overlaid badges to icon-plus-number cells matching the reference row structure
  - Kept armor, stat chips, combat meta, and turn summary hidden so empty placeholder rows do not appear
- Notes:
  - Godot MCP play-scene, runtime scene-tree, and error-log checks passed with the corrected player-panel geometry.

## [2026-04-29] docs | Combat Player UI Redesign Brief

- Source: `docs/combat-player-ui.md`, user-provided combat screen screenshot
- Changed:
  - Created `docs/combat-player-ui.md`
  - Documented player-section visual problems and a design-focused fix for each issue
  - Added layout proportions, visual treatment guidance, phased implementation direction, and acceptance criteria
- Notes:
  - This is a design/implementation brief only; no runtime UI changes were made.

## [2026-04-29] code-change | Combat Player Section Cohesion Fix Pass

- Source: `scenes/combat/combat_player.tscn`, `scripts/combat/combat_player_controller.gd`, `docs/test_plan.md`, `wiki/features.md`
- Changed:
  - Added `VitalsFrame`, `ArmorBadge`, and `ArmorBadgeLabel` nodes under the combat player `VitalsPanel`
  - Rebalanced player panel layout rects to a clearer three-layer composition (`hero status`, `loadout`, `mastery`)
  - Updated HP presentation to `HP current / max` and added conditional Slay the Spire-inspired `BLOCK +N` armor badge visibility
  - Reworked empty equipment/consumable slot visuals to recessed silhouettes
  - Updated mastery cells to `icon + Lv N` labeling for non-debug readability
  - Updated `docs/test_plan.md` and `wiki/features.md` with verification notes and final behavior summary
- Notes:
  - Godot MCP `play_scene` and running scene-tree inspection confirmed player-panel node wiring and bounds in `res://scenes/combat/combat_player.tscn`.
  - Manual visual overlap/readability checks across target desktop/mobile aspect ratios remain required.

## [2026-04-29] code-change | Player HUD Level Badge Removal And Padding Tightening

- Source: `scripts/combat/combat_player_controller.gd`, `wiki/features.md`
- Changed:
  - Removed visible player-HUD level treatment by disabling `HeroLevelBadge` usage in runtime styling and layout flow
  - Tightened player-section spacing by moving loadout/mastery blocks upward and reducing internal loadout frame padding
  - Reduced top padding inside equipment/consumable rails and section labels for denser, cleaner vertical rhythm
  - Updated feature documentation to reflect that the level badge is no longer part of the visible player panel
- Notes:
  - This pass is UI-only and preserves existing combat/runtime data behavior.

## [2026-04-29] code-change | Player HUD Full-Width And Mastery Token Rebuild

- Source: `scripts/combat/combat_player_controller.gd`, `wiki/features.md`
- Changed:
  - Expanded player HUD bounds to full design width and rebalanced top-row geometry for cleaner portrait-to-vitals alignment
  - Kept a clear vertical gap between top status row and loadout row by separating row bounds with explicit spacing
  - Rebuilt mastery entries as fixed token cells with centered `icon + numeric value` (removed `Lv` wording)
  - Tuned mastery strip sizing and icon-row spacing to avoid cramped labels and overflow
- Notes:
  - This pass is visual/UI-only and does not change combat, progression, or content logic.

## [2026-04-29] code-change | Player HUD Reference Layout Correction

- Source: `scripts/combat/combat_player_controller.gd`, `scenes/combat/combat_player.tscn`
- Changed:
  - Kept the player HUD full-width while restoring the top row to a taller portrait/status block
  - Moved the loadout row down to create a real margin below the top row
  - Rebuilt mastery as one fixed-position strip of icon/value pairs instead of boxed `Lv` cells or nested container cards
  - Converted `MasteryRoot` and `MasteryIcons` to plain `Control` nodes so the row no longer expands from container minimum sizing
- Notes:
  - Godot MCP script parse and running scene-tree checks passed for the corrected player panel and mastery strip bounds.

## [2026-04-29] code-change | Player HUD Bottom Stick And Loadout Padding

- Source: `scripts/combat/combat_player_controller.gd`
- Changed:
  - Moved the player HUD to the bottom edge of the 1080x1920 design space by setting `PlayerPanel` to `y=1452` with height `468`
  - Increased `LoadoutFrame` height to add lower padding below the equipment and consumable slots
  - Moved `MasteryStrip` down to preserve spacing after the loadout padding increase
- Notes:
  - Godot MCP parse, scene load, play-scene, and running scene-tree checks passed; runtime bounds confirmed the player HUD bottom is exactly `1920`.

## [2026-04-29] code-change | Player HUD Padding Refinement

- Source: `scripts/combat/combat_player_controller.gd`
- Changed:
  - Increased loadout frame height and inset the equipment/consumable slot rails to add clearer internal padding
  - Moved mastery lower while preserving an explicit bottom gutter inside the sticky player HUD
  - Kept the portrait content inset within the hero card instead of reintroducing the hidden level badge
- Notes:
  - Godot MCP parse and refreshed running scene-tree checks confirmed the updated player-panel, loadout, mastery, and portrait bounds.

## [2026-04-29] code-change | Board Outcome Summary And Next Button Move

- Source: `scenes/combat/combat_player.tscn`, `scripts/combat/combat_player_controller.gd`, `wiki/features.md`
- Changed:
  - Moved `NextButton` from the player HUD into a new hidden board-level `OutcomeSummaryPanel`
  - Added `BoardShadow` behind `BoardSurface` and lowered the board to make room for the summary panel above it
  - Rewired victory/debug-victory flow to show the board outcome summary with the continue button, while player HUD stays focused on player status/loadout/mastery
  - Updated feature documentation for the board outcome overlay behavior
- Notes:
  - Godot MCP parse, scene load, play-scene, and board subtree inspection passed; manual visual review of the visible victory summary remains useful.

## [2026-04-29] code-change | Centered Victory Outcome Card

- Source: `scenes/combat/combat_player.tscn`, `scripts/combat/combat_player_controller.gd`, `wiki/features.md`
- Changed:
  - Enlarged and centered the board-level `OutcomeSummaryPanel` so victory reads as a modal card instead of a cramped banner
  - Updated victory summary copy to show `Victory` and `GOLD GAINED +N`
  - Renamed the outcome action button from `Next` to `Continue`
  - Centered the outcome title, gold summary, and button within the card
- Notes:
  - This is a UI-only polish pass for victory outcome presentation.

## [2026-04-29] code-change | Larger Combat Debug Overlay Text

- Source: `scenes/combat/combat_player.tscn`, `scripts/combat/combat_player_controller.gd`, `wiki/features.md`
- Changed:
  - Added explicit debug overlay font sizing for status text, enemy debug text, combat log text, and command input
  - Increased the console input minimum height to make the command area at least 1.5x larger
  - Increased debug overlay internal spacing to match the larger typography
  - Updated feature documentation for the debug overlay readability pass
- Notes:
  - This is a UI-only debug readability change.

## [2026-04-29] code-change | Double Combat Debug Overlay Font Size

- Source: `scenes/combat/combat_player.tscn`, `scripts/combat/combat_player_controller.gd`
- Changed:
  - Doubled combat debug overlay font constants from 18px to 36px
  - Increased debug console input minimum height from 54px to 96px
- Notes:
  - This is a UI-only adjustment after visual review showed the previous debug text was still too small.

## [2026-04-29] code-change | Tune Combat Debug Overlay Font Size

- Source: `scenes/combat/combat_player.tscn`, `scripts/combat/combat_player_controller.gd`
- Changed:
  - Adjusted combat debug overlay font constants from 36px down to 24px
  - Adjusted debug console input minimum height from 96px down to 72px
- Notes:
  - This is a UI-only tuning pass after 36px proved too large.

## [2026-04-29] code-change | Shop UI Revamp

- Source: `scenes/flow/shop_player.tscn`, `scripts/flow/shop_player.gd`, `scripts/ui/visual_registry.gd`, `wiki/features.md`
- Changed:
  - Rebuilt the shop scene around a portrait merchant layout root with explicit runtime zones for top bar, merchant stage, stock cards, relic card, actions, build panel, mastery strip, and booster overlay
  - Replaced the old text-list offers and sell `SpinBox` with card-based buying, selectable equipment sell slots, and large primary action buttons
  - Added a stable booster icon placeholder path in `VisualRegistry` so missing booster art does not trigger repeated fallback warnings
  - Updated `wiki/features.md` for the player-facing shop UI structure
- Notes:
  - This is a presentation and interaction polish pass; shop economy and service mechanics remain unchanged.

## [2026-04-29] code-change | Shared Player Loadout HUD

- Source: `scripts/ui/player_loadout_hud.gd`, `scripts/combat/combat_player_controller.gd`, `scripts/flow/shop_player.gd`, `wiki/features.md`, `wiki/file-map.md`
- Changed:
  - Extracted combat loadout/mastery rendering into reusable `PlayerLoadoutHud`
  - Rewired combat and shop to render equipment slots, consumable slots, relic icons, mastery cells, empty silhouettes, and slot badges through the shared helper
  - Kept shop-specific selling behavior by using the helper's selectable equipment-slot signal
  - Updated wiki feature and file-map documentation for the shared UI helper
- Notes:
  - Godot MCP script reload and scene instantiate checks passed for combat and shop; combat runtime smoke confirmed shared loadout/mastery nodes in the running scene.

## [2026-04-29] code-change | Combat-Style Shop Player HUD

- Source: `scripts/ui/player_loadout_hud.gd`, `scripts/combat/combat_player_controller.gd`, `scripts/flow/shop_player.gd`, `wiki/features.md`
- Changed:
  - Moved combat player-panel geometry into `PlayerLoadoutHud.apply_combat_player_panel_layout`
  - Updated combat to call the shared layout helper for its player HUD geometry
  - Replaced the shop-only build panel and separate mastery strip with a `PlayerPanel` using combat HUD subzones: `HeroCard`, `VitalsPanel`, `LoadoutFrame`, and `MasteryStrip`
  - Kept shop-specific gold badge and selectable equipment slots inside the shared combat-style HUD structure
- Notes:
  - Godot MCP script reload, shop/combat scene instantiation, combat runtime HUD tree, and shop no-active-run runtime checks passed.

## [2026-04-29] code-change | Post-Drag Result Overlay Sequence

- Source: `scenes/combat/combat_player.tscn`, `scripts/combat/combat_player_controller.gd`, `wiki/features.md`
- Changed:
  - Added board-level top and bottom edge overlay cards under `BoardPanel` for post-drag combat feedback
  - Added combo-first display right after drag resolve starts, then step-sequenced post-turn cards for damage calculator formulas, player effects, and enemy block/intent effects
  - Reused existing turn-log fields from `CombatStateMachine.resolve_player_turn()` to format player-facing substituted formulas and effect summaries without changing combat math
  - Kept victory/defeat on the existing centered outcome panel and ensured post-drag overlays hide before outcome flow
  - Updated feature documentation with the new post-drag overlay behavior
- Notes:
  - Godot MCP scene load/instantiate checks passed and runtime error checks reported no session errors.

## [2026-04-29] code-change | Combo Floating Text Pivot

- Source: `scripts/combat/combat_player_controller.gd`, `scenes/combat/combat_player.tscn`, `wiki/features.md`
- Changed:
  - Removed the post-drag edge-card result sequence and its damage/effect calculator presentation path
  - Added floating `COMBO xN` text popups on board-space near each matched resolver group via `_on_resolver_match_found`
  - Implemented pop + rise + fade combo text animation directly in the existing `VfxLayer` so combo feedback appears close to match locations during cascades
  - Cleaned now-unused post-drag scene nodes from `combat_player.tscn`
  - Updated feature documentation to describe the combo-floating behavior
- Notes:
  - Godot MCP load/instantiate checks passed for `res://scenes/combat/combat_player.tscn`.
  - Current runtime warnings are existing `VisualRegistry` fallback icon warnings, not parse/runtime script errors from this change.

## [2026-04-29] code-change | Cascade Combo Popup Timing Fix

- Source: `scripts/combat/combat_player_controller.gd`, `wiki/features.md`
- Changed:
  - Moved combo popup emission from resolver `match_found` callback timing to per-pass timing inside `_play_resolve_animations`
  - Kept combo counter progression (`x1`, `x2`, ...) but now increments and renders in the same order as visible cascade passes
  - Updated feature note to reflect per-pass animation-loop emission
- Notes:
  - Fix targets visibility timing only; combat resolution math is unchanged.

## [2026-04-29] code-change | Equipment Mastery Relic Asset Polish Pass

- Source: `tools/asset_tools/clean_derived_icons.py`, `resources/art/first_pass/derived/icons/`, `scripts/ui/player_loadout_hud.gd`, `scripts/combat/combat_player_controller.gd`, `scripts/flow/shop_player.gd`, `scripts/flow/boss_relic_reward.gd`
- Changed:
  - Created `tools/asset_tools/clean_derived_icons.py` to strip checkerboard backgrounds, restore icon alpha, and normalize derived icon canvas sizing
  - Reprocessed derived icon assets used by equipment, mastery, relics, and shared item card paths under `resources/art/first_pass/derived/icons/`
  - Added compact owned-relic rendering with overflow handling in `PlayerLoadoutHud` and rewired combat/shop to use it
  - Kept combat relic visibility for compact layouts (still hidden for low-vertical layouts) and exposed owned relics in the shop footer
  - Upgraded boss relic reward option buttons to visual card presentation with icon, rarity tint, and description text
  - Updated `wiki/features.md`, `wiki/file-map.md`, and `docs/test_plan.md`
- Notes:
  - Gameplay logic, pricing, progression math, and content IDs were unchanged.
  - Godot MCP verification remains pending in this thread because MCP tools were not exposed.

## [2026-04-29] docs | Rename Project to Orbwalker

- Source: `project.godot`, `scenes/main.tscn`, `docs/game_design_document.md`, `docs/system_architecture.md`, `docs/test_plan.md`, `todo.md`
- Changed:
  - Renamed the Godot project to `Orbwalker`
  - Updated the main menu title and start button copy to match the new game name
  - Renamed the active design, architecture, QA, todo, and wiki titles to `Orbwalker`
- Notes:
  - Historical log entries were left unchanged.

## [2026-04-29] docs | Main Menu Art Package

- Source: `resources/art/first_pass/menu/`, `resources/visual/first_pass_asset_map.json`, `wiki/main-menu-assets.md`, `wiki/index.md`, `wiki/file-map.md`, `wiki/features.md`
- Changed:
  - Added the generated main menu art package under `resources/art/first_pass/menu/`
  - Extended `resources/visual/first_pass_asset_map.json` with a `menu` mapping block for the background, logo, border, button plates, stat panel, menu icons, and reused mastery icons
  - Created `wiki/main-menu-assets.md` to document the generated assets and reuse rules
  - Updated `wiki/index.md`, `wiki/file-map.md`, and `wiki/features.md` to point at the new menu art package
- Notes:
  - The main menu scene still needs runtime wiring before the new art is used in-game.

## [2026-04-29] docs | Main Menu HTML Layout Guide

- Source: `docs/main_menu_layout_guide.html`, `wiki/main-menu-assets.md`
- Changed:
  - Added `docs/main_menu_layout_guide.html` with a 9:16 overlay mock, zone boundaries, safe area, and asset slot table for menu implementation planning
  - Updated `wiki/main-menu-assets.md` sources and important files to include the HTML guide
- Notes:
  - This guide is documentation-only; runtime scene wiring is still pending.

## [2026-04-29] docs | Main Menu HTML Recreation Prototype

- Source: `docs/main_menu_recreation.html`, `wiki/main-menu-assets.md`
- Changed:
  - Added `docs/main_menu_recreation.html` to visually recreate the reference main menu using the generated menu art pack and reused mastery icons
  - Updated `wiki/main-menu-assets.md` to include the HTML recreation artifact
- Notes:
  - This is an HTML prototype for visual matching; it does not change Godot runtime scene behavior.

## [2026-04-30] docs | Main Menu HTML Prototype Correction Pass

- Source: `docs/main_menu_recreation.html`, `resources/art/first_pass/menu/main_menu_logo_orbwalker_v1_alpha.png`, `resources/visual/first_pass_asset_map.json`, `wiki/main-menu-assets.md`
- Changed:
  - Corrected the HTML recreation composition with fixed section coordinates and tuned typography/spacing for closer visual parity with the reference menu
  - Created `main_menu_logo_orbwalker_v1_alpha.png` and switched the HTML logo usage to the transparent variant
  - Updated the menu asset map `menu.logo` entry to the alpha logo path
  - Updated `wiki/main-menu-assets.md` with alpha logo documentation and revised update date
- Notes:
  - The main issue reported in the screenshot was the non-transparent logo background and oversized section layout in the first HTML pass.
