# Main Menu Assets

**Summary**: Inventory and map for the generated main menu art package. This page records the new menu background, logo, UI chrome, stat panel, and icon assets, plus the existing mastery icons that are reused for the elemental row.

**Sources**: `resources/art/first_pass/menu/`, `resources/art/first_pass/derived/icons/mastery_fire.png`, `resources/art/first_pass/derived/icons/mastery_ice.png`, `resources/art/first_pass/derived/icons/mastery_earth.png`, `resources/art/first_pass/derived/icons/mastery_heart.png`, `resources/art/first_pass/derived/icons/mastery_armor.png`, `resources/art/first_pass/derived/icons/mastery_gold.png`, `resources/visual/first_pass_asset_map.json`, `docs/main_menu_layout_guide.html`, `docs/main_menu_recreation.html`, `scenes/main.tscn`, `scripts/ui/visual_registry.gd`

**Last updated**: 2026-04-30

---

## Overview

The menu art package now lives under `resources/art/first_pass/menu/` and is documented in `resources/visual/first_pass_asset_map.json`. The package covers the vertical background plate, the title logo, the outer border, the primary and secondary button plates, the three-column status strip, and the six menu-specific stat icons. (source: `resources/art/first_pass/menu/`, `resources/visual/first_pass_asset_map.json`)

The six elemental row icons are reused from the existing mastery icon family instead of being regenerated. (source: `resources/art/first_pass/derived/icons/mastery_fire.png`, `resources/art/first_pass/derived/icons/mastery_ice.png`, `resources/art/first_pass/derived/icons/mastery_earth.png`, `resources/art/first_pass/derived/icons/mastery_heart.png`, `resources/art/first_pass/derived/icons/mastery_armor.png`, `resources/art/first_pass/derived/icons/mastery_gold.png`)

The runtime main menu scene is now wired to the menu art package for background, logo, outer border, button chrome, stats panel chrome, and menu icon sets through the asset map. The generated chrome/icon PNGs have been cleaned so transparent regions are real alpha instead of baked checkerboard pixels. (source: `scenes/main.tscn`, `scripts/core/main_boot.gd`, `resources/visual/first_pass_asset_map.json`, `tools/asset_tools/clean_menu_art.py`)

## Details

### Generated menu art

- `resources/art/first_pass/menu/main_menu_bg_orbwalker_cavern_city_v1.png` - vertical dungeon-city background plate for the main menu.
- `resources/art/first_pass/menu/main_menu_logo_orbwalker_v1.png` - original logo wordmark export (fully opaque background).
- `resources/art/first_pass/menu/main_menu_logo_orbwalker_v1_alpha.png` - cleaned transparent logo wordmark used at runtime; enclosed checkerboard regions were removed in the 2026-04-30 MCP validation pass.
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

The mapped `menu.logo` path now points to the cleaned alpha logo variant to avoid white/checkerboard background bleed in UI composition prototypes. (source: `resources/visual/first_pass_asset_map.json`, `resources/art/first_pass/menu/main_menu_logo_orbwalker_v1_alpha.png`)

### Runtime defect remediation (2026-04-30)

- Resolved logo clipping and menu overlap caused by native texture-size expansion in runtime layout.
- Resolved elemental row/stats/footer overflow caused by unbounded icon minimum sizes.
- Resolved footer panel blowout and bottom text collisions by clamping runtime icon sizes and simplifying bottom label usage.
- Resolution is implemented in runtime scene composition code, not by changing source art dimensions. (source: `scripts/core/main_boot.gd`, `docs/test_plan.md`)

### Runtime reference-match pass (2026-04-30)

- Main menu now uses generated `menu.button_primary` and `menu.button_secondary` textures at runtime for action and footer button chrome.
- Main menu `StatsPanel` now uses generated `menu.stats_panel` texture at runtime.
- Main menu stats and footer iconography now uses generated `menu.menu_icons` mappings at runtime instead of progression-item fallback icons.
- Main menu no longer exposes a visible debug combat button; `Start Run` remains the only functional player-facing action. (source: `scenes/main.tscn`, `scripts/core/main_boot.gd`, `docs/test_plan.md`)

### Checkerboard alpha cleanup (2026-04-30)

- `tools/asset_tools/clean_menu_art.py` removes baked checkerboard pixels from generated menu chrome/icon PNGs and rewrites them with real transparent alpha.
- Cleaned assets include the outer border, primary/secondary button plates, stats triptych panel, and all `main_menu_icon_*` files.
- `scripts/core/main_boot.gd` now uses zero texture-slice margins for these highly compressed runtime button/panel plates so the cleaned art remains visible in the current menu layout. (source: `tools/asset_tools/clean_menu_art.py`, `scripts/core/main_boot.gd`, `docs/test_plan.md`)

## Important Files

- `resources/art/first_pass/menu/` - generated menu art package.
- `resources/visual/first_pass_asset_map.json` - JSON map for the new menu art package and the reused mastery icons.
- `docs/main_menu_layout_guide.html` - HTML overlay and slot map for main menu composition/layout planning.
- `docs/main_menu_recreation.html` - HTML visual recreation of the reference menu using the generated art pack.
- `scenes/main.tscn` - authored main menu scene with background/logo zones, textured border, button stack, element row, stats panel, and footer actions.
- `scripts/core/main_boot.gd` - main menu runtime layout, menu asset-map texture binding, textured styleboxes for buttons/panels, and `Start Run` behavior wiring.
- `tools/asset_tools/clean_menu_art.py` - menu chrome/icon alpha cleanup utility for generated assets with baked checkerboard backgrounds.
- `scripts/ui/visual_registry.gd` - still does not expose dedicated menu accessors; main menu currently reads mapped paths directly.

## Open Questions

- Should main menu textures be migrated behind dedicated `VisualRegistry` accessors in a later cleanup pass. (needs verification)
- Should the menu icon family stay in `resources/art/first_pass/menu/`, or be split into a future `resources/art/first_pass/derived/menu/` family if iteration continues? (needs verification)

## Related Pages

- [[file-map]]
- [[features]]
