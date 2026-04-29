# Main Menu Assets

**Summary**: Inventory and map for the generated main menu art package. This page records the new menu background, logo, UI chrome, stat panel, and icon assets, plus the existing mastery icons that are reused for the elemental row.

**Sources**: `resources/art/first_pass/menu/`, `resources/art/first_pass/derived/icons/mastery_fire.png`, `resources/art/first_pass/derived/icons/mastery_ice.png`, `resources/art/first_pass/derived/icons/mastery_earth.png`, `resources/art/first_pass/derived/icons/mastery_heart.png`, `resources/art/first_pass/derived/icons/mastery_armor.png`, `resources/art/first_pass/derived/icons/mastery_gold.png`, `resources/visual/first_pass_asset_map.json`, `scenes/main.tscn`, `scripts/ui/visual_registry.gd`

**Last updated**: 2026-04-29

---

## Overview

The menu art package now lives under `resources/art/first_pass/menu/` and is documented in `resources/visual/first_pass_asset_map.json`. The package covers the vertical background plate, the title logo, the outer border, the primary and secondary button plates, the three-column status strip, and the six menu-specific stat icons. (source: `resources/art/first_pass/menu/`, `resources/visual/first_pass_asset_map.json`)

The six elemental row icons are reused from the existing mastery icon family instead of being regenerated. (source: `resources/art/first_pass/derived/icons/mastery_fire.png`, `resources/art/first_pass/derived/icons/mastery_ice.png`, `resources/art/first_pass/derived/icons/mastery_earth.png`, `resources/art/first_pass/derived/icons/mastery_heart.png`, `resources/art/first_pass/derived/icons/mastery_armor.png`, `resources/art/first_pass/derived/icons/mastery_gold.png`)

The menu assets are documented, but the runtime main menu scene still needs wiring before these files are used in-game. (source: `scenes/main.tscn`, `scripts/ui/visual_registry.gd`)

## Details

### Generated menu art

- `resources/art/first_pass/menu/main_menu_bg_orbwalker_cavern_city_v1.png` - vertical dungeon-city background plate for the main menu.
- `resources/art/first_pass/menu/main_menu_logo_orbwalker_v1.png` - logo wordmark with integrated compass emblem.
- `resources/art/first_pass/menu/main_menu_border_outer_v1.png` - ornate outer screen border.
- `resources/art/first_pass/menu/main_menu_button_primary_v1.png` - highlighted primary action button plate.
- `resources/art/first_pass/menu/main_menu_button_secondary_v1.png` - darker secondary button plate.
- `resources/art/first_pass/menu/main_menu_stats_triptych_panel_v1.png` - three-column status panel for relics, mastery, and best run.
- `resources/art/first_pass/menu/main_menu_icon_relic_chest_v1.png` - relics-unlocked icon.
- `resources/art/first_pass/menu/main_menu_icon_mastery_progress_v1.png` - mastery-progress compass icon.
- `resources/art/first_pass/menu/main_menu_icon_best_run_demon_v1.png` - best-run demon/skull icon.
- `resources/art/first_pass/menu/main_menu_icon_profile_v1.png` - profile icon.
- `resources/art/first_pass/menu/main_menu_icon_achievements_v1.png` - achievements icon.
- `resources/art/first_pass/menu/main_menu_icon_settings_v1.png` - settings icon.

### Reused mastery icons

- `resources/art/first_pass/derived/icons/mastery_fire.png`
- `resources/art/first_pass/derived/icons/mastery_ice.png`
- `resources/art/first_pass/derived/icons/mastery_earth.png`
- `resources/art/first_pass/derived/icons/mastery_heart.png`
- `resources/art/first_pass/derived/icons/mastery_armor.png`
- `resources/art/first_pass/derived/icons/mastery_gold.png`

### Asset map

`resources/visual/first_pass_asset_map.json` now includes a `menu` section with:

- `background`
- `logo`
- `outer_border`
- `button_primary`
- `button_secondary`
- `stats_panel`
- `menu_icons`
- `reused_mastery_icons`

This keeps the menu-specific art package separated from the combat and shop art families. (source: `resources/visual/first_pass_asset_map.json`)

## Important Files

- `resources/art/first_pass/menu/` - generated menu art package.
- `resources/visual/first_pass_asset_map.json` - JSON map for the new menu art package and the reused mastery icons.
- `scripts/ui/visual_registry.gd` - current runtime registry; does not yet expose dedicated menu accessors.
- `scenes/main.tscn` - main menu scene that still needs wiring to the new art package.

## Open Questions

- Should the menu art be loaded through `VisualRegistry`, or should `scenes/main.tscn` load the files directly? (needs verification)
- Should the menu icon family stay in `resources/art/first_pass/menu/`, or be split into a future `resources/art/first_pass/derived/menu/` family if iteration continues? (needs verification)

## Related Pages

- [[file-map]]
- [[features]]
