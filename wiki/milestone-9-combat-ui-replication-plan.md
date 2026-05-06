# Milestone 9 Combat UI Replication Plan

**Summary**: Implementation plan to replicate the provided combat reference composition in Orbwalker's player-facing combat scene, with close-match fidelity and no mana system changes.

**Sources**: `todo.md`, `docs/test_plan.md`, `scenes/combat.tscn`, `scripts/scenes/combat.gd`, `scripts/ui/visual_registry.gd`, `C:/Users/Home/Desktop/combat-ref.png`

**Last updated**: 2026-04-29

---

## Overview

Milestone 9 is mostly complete, but this plan defines the remaining combat UI/game-feel pass to align the player-facing combat screen with the approved reference composition. This is a combat-only pass and does not add new gameplay systems. (source: `todo.md`, `docs/test_plan.md`)

## Details

- Target fidelity is a close layout and visual-weight match, not pixel-identical art recreation. (source: `C:/Users/Home/Desktop/combat-ref.png`)
- Scope is combat scene UI only for this pass. Shop and reward scenes are out of scope for this specific plan. (source: `scripts/scenes/combat.gd`)
- The blue secondary bar in the reference is treated as styling, not a new mana mechanic; no new combat resource is introduced. (source: `scripts/scenes/combat.gd`)
- Combat screen should be structured into six bands:
  - Top bar (dungeon step, gold, utility buttons)
  - Enemy stage (intent badge/text, enemy art, enemy HP)
  - Tempo strip (timer badge/bar + combo/damage callout)
  - Board zone (framed board)
  - Hero panel (portrait, HP/armor bars, key stat strip)
  - Build footer (equipment, consumables with counts, mastery row)
- Existing runtime data remains the source for all shown values (run progress, hp/armor/gold, timer, enemy intent/hp, combo summary, progression slots). (source: `scripts/scenes/combat.gd`)
- Existing visual assets and registry should be reused first, replacing flat fallback chrome where available with texture-backed frame/bar/badge styles. (source: `scripts/ui/visual_registry.gd`)

## Important Files

- `scenes/combat.tscn` - Primary combat HUD structure to reshape to reference composition.
- `scripts/scenes/combat.gd` - HUD data binding, formatting, responsive behavior, and visual style wiring.
- `scripts/ui/visual_registry.gd` - Texture lookup contract for chrome, bars, badges, icons, and fallbacks.
- `resources/art/first_pass/derived/hud/` - Existing derived timer/intent/bar/badge assets to prefer over flat styles.
- `resources/art/first_pass/derived/ui_chrome/` - Existing frame/divider/slot chrome assets for panel and footer styling.

## Test Cases

- Layout parity pass on desktop: verify composition readability and section hierarchy against reference at `1920x1080` and `1366x768`. (source: `docs/test_plan.md`)
- Layout overlap pass on portrait/mobile-style ratios: `900x1600` and `1080x1920`, with no critical overlap or clipped controls. (source: `docs/test_plan.md`)
- Functional HUD correctness during combat:
  - HP/armor/gold update after a turn.
  - Enemy HP and intent update per turn.
  - Timer and combo/damage callout update through input/resolve.
- Regression sanity:
  - Start fight, resolve turns, and transition to victory/defeat without HUD-breaking errors.
  - Debug overlay remains hidden by default but still toggleable for development use.

## Open Questions

- Whether the same visual hierarchy should be mirrored in shop and boss-reward scenes in a later Milestone 9 follow-up. (needs verification)

## Related Pages

- [[features]]
- [[known-issues]]
- [[open-questions]]
