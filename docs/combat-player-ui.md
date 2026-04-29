# Combat Player UI Redesign Implementation Brief

**Summary**: Design findings and implementation-facing direction for fixing the player section in the combat screen. This document focuses on visual hierarchy, layout, and readability, not gameplay rule changes.

**Sources**: User-provided combat screen screenshot and critique request from 2026-04-29, `docs/game_design_document.md`, `docs/test_plan.md`, `todo.md`, `scenes/combat/combat_player.tscn`, `scripts/combat/combat_player_controller.gd`

**Last updated**: 2026-04-29

---

## Goal

Turn the bottom player section into a clear combat status console: the player should immediately understand hero condition, available build resources, empty slot capacity, and mastery progress without the section feeling like placeholder debug UI. The board remains the primary interaction area; the player section should support decisions rather than compete with it. (source: user-provided combat screen screenshot, `docs/game_design_document.md`)

The current combat player scene already has first-class nodes for `PlayerPanel`, `HeroCard`, `VitalsPanel`, `LoadoutFrame`, and `MasteryStrip`, so the redesign should preserve that conceptual split while improving composition and visual treatment. (source: `scenes/combat/combat_player.tscn`, `scripts/combat/combat_player_controller.gd`)

## Design Principles

- Make the player section read as one designed HUD, not separate widgets placed in a large box. (source: user-provided combat screen screenshot)
- Use strong hierarchy: hero identity first, HP/status second, held build resources third, mastery progression fourth. (source: `docs/game_design_document.md`)
- Empty slots must still look intentional because the prototype has fixed 5 equipment slots and 3 consumable slots. (source: `docs/game_design_document.md`, `scripts/combat/player_state.gd`)
- Show combat-relevant state only when it helps decision making; avoid rows of placeholder values that look like debug output. (source: user-provided combat screen screenshot)
- Keep the redesign compatible with portrait-first composition and pending desktop/mobile overlap checks. (source: `project.godot`, `docs/test_plan.md`)

## Proposed Layout

Use three horizontal layers inside the player panel:

1. **Hero status layer**: left hero card, right HP/status block.
2. **Loadout layer**: equipment rail and consumable rail with clear headers and slot affordance.
3. **Mastery layer**: full-width compact mastery row with one consistent cell per orb type.

Recommended proportions for the existing 468 px design-space player panel height:

| Layer | Approximate Height | Purpose |
| --- | ---: | --- |
| Hero status | 180-210 px | Portrait, level, HP, conditional armor/status |
| Loadout | 135-155 px | 5 equipment slots, 3 consumable slots |
| Mastery | 55-70 px | Six mastery tracks |

The exact pixel values can change during implementation, but these proportions keep the top area from feeling empty while giving loadout and mastery enough room to breathe. (source: `scripts/combat/combat_player_controller.gd`)

## Problem And Fix List

| Problem | Design Fix |
| --- | --- |
| 1. The section feels unfinished and placeholder-like. | Give the section a deliberate three-layer HUD structure: hero status, loadout, mastery. Each layer should have a clear job and visual boundary. |
| 2. The player portrait is too small. | Enlarge the portrait card and make it the left anchor of the player section. The portrait should be visually comparable to a combat status card, not a small icon. |
| 3. The portrait frame and level badge are weak. | Treat the portrait as a character card with a stronger frame, inset art area, and integrated `Lv. 1` badge. The badge should attach to the frame instead of floating awkwardly. |
| 4. The HP bar is oversized but generic. | Convert HP into a framed vitals module with a darker track, clear fill, subtle bevel, and optional damage-preview space. The bar can stay long, but it needs structure. |
| 5. The HP text is weakly integrated. | Add an `HP` label or heart icon beside `100 / 100`, and style the number as combat status text rather than raw debug text. |
| 6. Portrait and HP spacing feels disconnected. | Group portrait and vitals into one hero status block. Align the HP bar to the portrait height and add hero name/level context above or beside it. |
| 7. Equipment and consumable areas look broken when empty. | Add designed empty-slot states: faint category silhouettes, recessed sockets, locked-slot styling if unavailable, or subtle placeholder icons. |
| 8. Slots have low contrast. | Use a darker inner slot, brighter edge, and soft highlight/shadow so empty slots remain visible against the panel background. |
| 9. `EQUIPMENT` and `CONSUMABLES` labels are too weak. | Use icon-plus-label headers, stronger contrast, and direct alignment above each rail. The labels should scan before the individual slots. |
| 10. The mastery strip is cramped. | Allocate a dedicated full-width strip with consistent cell widths, equal spacing, and larger icons or badges. |
| 11. Mastery looks like debug counters. | Replace repeated bare `0` values with designed level cells: orb icon plus level badge, pips, or a small `Lv 0` tag inside each cell. |
| 12. The panel lacks clear grouping. | Use subpanel backgrounds or separators for hero status, loadout, and mastery. Keep borders lighter than the outer frame. |
| 13. Space distribution is inconsistent. | Reduce unused upper-panel void and give that space to loadout and mastery breathing room. The player panel should feel dense but not compressed. |
| 14. Gold borders are too heavy. | Reserve gold for outer frame, active highlights, and important badges. Use neutral dark dividers for secondary grouping. |
| 15. The bottom area feels visually flat. | Add controlled depth: recessed panels, inner shadows, small highlights, and different background tones for status, slot rails, and mastery. |
| 16. The section communicates too little state. | Show HP always, armor/block conditionally when relevant, slot availability, consumable charges, and mastery progress. Avoid showing inactive placeholder bars. |
| 17. Alignment feels arbitrary. | Put all player-section elements on a strict shared grid with consistent left/right margins and vertical baselines. |
| 18. The player HUD feels less important than the board. | Increase player-section confidence through a stronger hero card, clearer HP module, and cleaner resource rows while keeping board interaction visually dominant. |

## Information Hierarchy

The player section should answer these questions in order:

1. **Am I alive and stable?** Use portrait, HP, and conditional armor/block/status. HP persists through the run, and armor reduces incoming damage before HP. (source: `docs/game_design_document.md`, `scripts/combat/player_state.gd`)
2. **What build tools do I currently have?** Show 5 equipment slots and 3 consumable slots as always-visible rails. Equipment and consumables are core run progression surfaces. (source: `docs/game_design_document.md`, `docs/test_plan.md`)
3. **What scaling am I building toward?** Show all six mastery tracks in a compact, non-debug row. Mastery exists for Fire, Ice, Earth, Heart, Armor, and Gold. (source: `docs/game_design_document.md`)

## Visual Treatment

- Background: use a slightly different dark panel tone for each major layer so grouping is visible without adding more heavy borders.
- Borders: outer player panel can keep a gold accent; internal panels should use thinner, darker, lower-contrast frames.
- Portrait: make the hero card tactile, with an inset art plate and a level badge that overlaps the frame intentionally.
- HP: red fill is acceptable, but it needs a clear dark track, better label treatment, and enough padding so the number does not feel pasted on.
- Slots: empty slots should be readable from the board-view distance. Use consistent socket size and a small type/icon cue for slot category.
- Mastery: each orb type should have a fixed-size cell with icon and level treatment. Avoid tiny icons followed by free-floating numbers.
- Typography: use fewer all-caps micro-labels. Reserve all-caps for section headers and use larger numeric text for HP and levels.

## Implementation Phases

1. **Wireframe pass**
   - Lock the three-layer structure.
   - Align portrait, HP, loadout, and mastery to one grid.
   - Remove excess empty panel space before adding decorative treatment.

2. **Hierarchy pass**
   - Increase portrait and HP prominence.
   - Make equipment/consumable headers readable.
   - Convert mastery cells from debug-style counters to designed level cells.

3. **Empty-state pass**
   - Design visible empty equipment slots.
   - Design visible empty consumable slots.
   - Add slot affordance states for empty, filled, disabled/locked if needed, and selected/active if later supported.

4. **State pass**
   - Show HP always.
   - Show armor/block only when relevant or as a compact shield badge.
   - Show consumable charges and item quantities in badges.
   - Keep debug-only information out of the player-facing HUD.

5. **Responsive review pass**
   - Check the combat screen at `1080x1920`, `900x1600`, `1920x1080`, and `1366x768`.
   - Verify no HP text, slot label, mastery cell, or portrait badge overlaps.
   - Verify the board remains the primary focus and the player panel stays readable.

## Acceptance Criteria

- The player panel reads as one cohesive HUD section from a full-screen combat view.
- The hero portrait and HP bar form a clear player status block.
- Empty equipment and consumable slots look intentional and interactive, not missing.
- Equipment, consumables, and mastery each have readable labels and consistent spacing.
- Mastery levels are understandable without looking like raw debug counters.
- Gold accents are used for emphasis instead of outlining every nested box.
- The panel communicates HP, relevant defensive state, build inventory, and mastery progress without clutter.
- The layout passes manual visual review at portrait and desktop aspect ratios listed in `docs/test_plan.md`.

## Out Of Scope

- No new combat resources or mechanics.
- No changes to board rules, enemy behavior, shop logic, item effects, or mastery formulas.
- No requirement to redesign the enemy section in the same pass.
- No requirement to replace final art assets before the layout and hierarchy are fixed.

## Open Questions

- Should armor be visible as a small always-present shield value or only appear when armor is greater than zero?
- Should equipment and consumable empty slots use category silhouettes, rarity frames, or plain recessed sockets?
- Should mastery levels use numeric badges, pips, or both?
- Should relics remain outside this player panel or get a later compact treatment in the same bottom HUD?

