# Temporary Elemental Mastery Visual Issue Tracker

## Purpose

Track the current Elemental Mastery screenshot defects as concrete visual issues. This file is temporary and should be removed or folded into the main polish tracker after the section is accepted.

## Screenshot Context

- Area: `ElementalMasteryPanel` between the board and player HUD.
- Current source refs:
  - `scripts/combat/combat_player_controller.gd:138-141` controls board/mastery panel/title/card row rects.
  - `scripts/ui/player_loadout_hud.gd:15-17` controls combat mastery card size, gap, and icon size.
  - `scripts/ui/player_loadout_hud.gd:176-216` controls icon, title, level, and feedback label placement inside each card.

## Status Legend

- `[ ]` Open.
- `[~]` In progress.
- `[x]` Fixed and validated.
- `[!]` Blocked or needs design decision.

## Issues

- [ ] EM-01 Title overlaps the card row
  - Screenshot issue: `ELEMENTAL MASTERY` sits on top of the card row/borders instead of occupying a clean header band.
  - Target behavior: title has dedicated vertical space above cards with no overlap.
  - Current refs: `scripts/combat/combat_player_controller.gd:140-141`.
  - Validation notes: inspect `ElementalMasteryTitle` and `ElementalMasteryCards` bounds in Godot MCP scene tree.

- [ ] EM-02 Panel still reads as a shallow strip
  - Screenshot issue: the whole section feels compressed horizontally and vertically, closer to a stat strip than mastery cards.
  - Target behavior: card row reads as a deliberate card section with visible height and hierarchy.
  - Current refs: `scripts/combat/combat_player_controller.gd:139-141`, `scripts/ui/player_loadout_hud.gd:15`.
  - Validation notes: screenshot at default combat viewport; compare against reference-style tall card intent.

- [ ] EM-03 Level text is too close to the bottom edge
  - Screenshot issue: `Lv 0` sits near or on the lower card border.
  - Target behavior: level text has safe padding and does not visually touch card borders.
  - Current refs: `scripts/ui/player_loadout_hud.gd:201-208`.
  - Validation notes: inspect runtime `MasteryLevel` bounds against `CardPanel` bounds.

- [ ] EM-04 Feedback slot is not visually reserved
  - Screenshot issue: no clear lower slot for `+N DAMAGE/HEAL/ARMOR/GOLD`; feedback may feel like it appears on top of existing content.
  - Target behavior: each card has a clearly readable lower feedback lane.
  - Current refs: `scripts/ui/player_loadout_hud.gd:210-216`.
  - Validation notes: force nonzero mastery feedback and confirm it does not collide with level text or card border.

- [ ] EM-05 Outer frame and card borders visually collide
  - Screenshot issue: ornate panel frame, inner frame, and card borders stack tightly, especially along the top and bottom.
  - Target behavior: panel frame and cards have clear separation/padding.
  - Current refs: `scripts/combat/combat_player_controller.gd:139-141`, `scripts/ui/player_loadout_hud.gd:163-174`.
  - Validation notes: inspect card row position and padding against `ElementalMasteryPanelFrame`.

- [ ] EM-06 Vertical seam artifacts extend below cards
  - Screenshot issue: dark/blue vertical seams are visible below card bottoms between cards.
  - Target behavior: no card background, border, or separator artifacts extend outside card bounds.
  - Current refs: `scripts/ui/player_loadout_hud.gd:163-174`.
  - Validation notes: screenshot after scene start; inspect whether `CardPanel` textures or row clipping cause the seams.

- [ ] EM-07 Card backgrounds look cropped into slices
  - Screenshot issue: colored card textures appear clipped into horizontal slices instead of full framed cards.
  - Target behavior: card background art reads as a full framed card.
  - Current refs: `scripts/ui/player_loadout_hud.gd:171-174`.
  - Validation notes: verify `TextureRect.stretch_mode` and card aspect ratio against generated `mastery_card_*.png` assets.

- [ ] EM-08 Icon/text hierarchy is unbalanced
  - Screenshot issue: icons dominate the card while text is squeezed into tight lower rows.
  - Target behavior: icon remains readable, but title, level, and feedback have equal clarity.
  - Current refs: `scripts/ui/player_loadout_hud.gd:176-216`.
  - Validation notes: inspect at runtime scale and check readability without zooming.

- [ ] EM-09 Title z-order and framing are unclear
  - Screenshot issue: the title appears over the art/border stack rather than integrated into a header area.
  - Target behavior: title is either in a clear header band or visually separated from the card row.
  - Current refs: `scripts/combat/combat_player_controller.gd:140`, `scripts/combat/combat_player_controller.gd:2562-2592`.
  - Validation notes: inspect title draw order relative to `ElementalMasteryPanelFrame` and cards.

- [ ] EM-10 Too many competing borders
  - Screenshot issue: outer frame, inner frame, card frames, and texture borders create visual noise.
  - Target behavior: one clear outer frame plus distinct but quieter card frames.
  - Current refs: `scripts/combat/combat_player_controller.gd:2562-2592`, `scripts/ui/player_loadout_hud.gd:166-174`.
  - Validation notes: screenshot review after any frame/card texture adjustment.

- [ ] EM-11 Left and right padding feel tight
  - Screenshot issue: Fire and Gold cards sit close to the panel frame edge.
  - Target behavior: first and last cards have breathing room without overflowing six-card layout.
  - Current refs: `scripts/combat/combat_player_controller.gd:141`, `scripts/ui/player_loadout_hud.gd:15-17,163-164`.
  - Validation notes: confirm six cards still fit within `ElementalMasteryCards` after padding changes.

- [ ] EM-12 No inactive/ready/triggered state clarity
  - Screenshot issue: the panel shows levels but does not communicate ready, inactive, or recently triggered state.
  - Target behavior: idle state is readable, and triggered cards visibly change through feedback text, pulse, or glow.
  - Current refs: `scripts/combat/combat_player_controller.gd:1674-1708`, `scripts/ui/player_loadout_hud.gd:239-254`.
  - Validation notes: run a turn with damage/heal/armor/gold and confirm active cards visibly change.

- [ ] EM-13 Reference goal still not met
  - Screenshot issue: current result remains a compact row rather than a dramatic mastery section with clear cards.
  - Target behavior: closer to reference hierarchy: section title, large icon, clear card interior, prominent effect text.
  - Current refs: `scripts/combat/combat_player_controller.gd:138-141`, `scripts/ui/player_loadout_hud.gd:15-17,176-216`.
  - Validation notes: screenshot review against the reference image after layout changes.

## Validation Checklist

- [ ] Godot MCP `play_scene` current scene starts without errors.
- [ ] Godot MCP scene tree confirms title/card row bounds do not overlap.
- [ ] Six cards fit within `ElementalMasteryCards` without overflow.
- [ ] First and last cards have visible side padding.
- [ ] `MasteryIcon`, `MasteryLabel`, `MasteryLevel`, and `MasteryFeedback` do not overlap inside each card.
- [ ] Feedback text is visible when nonzero and hidden/quiet when zero.
- [ ] Manual screenshot confirms no seam artifacts, clipped backgrounds, or border collisions.

## Cleanup Criteria

- Remove this file after these issues are fixed and accepted.
- If the final visual design becomes durable, summarize it in `docs/test_plan.md` and the relevant wiki pages.
