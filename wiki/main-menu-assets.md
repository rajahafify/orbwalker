# Main Menu Assets

**Summary**: Inventory and map for the generated main menu art package. This page records the new menu background, logo, UI chrome, stat panel, and icon assets, plus the existing mastery icons that are reused for the elemental row.

**Sources**: `resources/art/first_pass/menu/`, `resources/art/assetgen/main_menu/`, `resources/art/first_pass/derived/icons/mastery_fire.png`, `resources/art/first_pass/derived/icons/mastery_ice.png`, `resources/art/first_pass/derived/icons/mastery_earth.png`, `resources/art/first_pass/derived/icons/mastery_heart.png`, `resources/art/first_pass/derived/icons/mastery_armor.png`, `resources/art/first_pass/derived/icons/mastery_gold.png`, `resources/visual/first_pass_asset_map.json`, `tools/asset_tools/extract_assetgen_main_menu_ui.py`, `tools/asset_tools/prepare_main_menu_logo_alpha.py`, `docs/main_menu_layout_guide.html`, `docs/main_menu_recreation.html`, `scenes/main_menu.tscn`, `scripts/main_menu/main_menu_view.gd`, `scripts/ui/visual_registry.gd`

**Last updated**: 2026-05-08

---

## Overview

The menu art package now lives under `resources/art/first_pass/menu/` and is documented in `resources/visual/first_pass_asset_map.json`. The package covers the vertical background plate, the title logo, the outer border, the primary and secondary button plates, the three-column status strip, and the six menu-specific stat icons. (source: `resources/art/first_pass/menu/`, `resources/visual/first_pass_asset_map.json`)

The six elemental row icons are reused from the existing mastery icon family instead of being regenerated. Current runtime menu polish hides the elemental row from the main-menu view without removing the assets or mappings, so this icon family remains available for future menu/UI use. (source: `resources/art/first_pass/derived/icons/mastery_fire.png`, `resources/art/first_pass/derived/icons/mastery_ice.png`, `resources/art/first_pass/derived/icons/mastery_earth.png`, `resources/art/first_pass/derived/icons/mastery_heart.png`, `resources/art/first_pass/derived/icons/mastery_armor.png`, `resources/art/first_pass/derived/icons/mastery_gold.png`, `scripts/main_menu/main_menu_view.gd`)

The runtime main menu scene is now wired to the menu art package for background, logo, outer border, button chrome, stats panel chrome, and menu icon sets through the asset map. The generated chrome/icon PNGs have been cleaned so transparent regions are real alpha instead of baked checkerboard pixels. (source: `scenes/main_menu.tscn`, `scripts/scenes/main_menu.gd`, `resources/visual/first_pass_asset_map.json`, `tools/asset_tools/clean_menu_art.py`)

The first assetgen runtime integration is main-menu only and includes the accepted background, deterministic candidate_05 UI pack slicing with post-slice cleanup/composition, and the cleaned generated title logo. `main_menu_background_candidate_01.png` is the mapped background, `tools/asset_tools/extract_assetgen_main_menu_ui.py` slices the approved candidate_05 sheet into runtime `outer_border`, `button_primary`, `button_secondary`, `stats_panel`, and semantic `menu_icons`, and `tools/asset_tools/prepare_main_menu_logo_alpha.py` creates the true-alpha runtime logo. Human visual review accepted this menu wiring on 2026-05-08, and the three involved asset records now use `integration_status: integrated_main_menu`. (source: `resources/art/assetgen/main_menu/`, `tools/asset_tools/extract_assetgen_main_menu_ui.py`, `tools/asset_tools/prepare_main_menu_logo_alpha.py`, `resources/visual/first_pass_asset_map.json`, `assets/generated/metadata/records/main_menu_background.json`, `assets/generated/metadata/records/main_menu_ui_pack.json`, `assets/generated/metadata/records/game_title_logo.json`)

## Details

### Generated menu art

- `resources/art/first_pass/menu/main_menu_bg_orbwalker_cavern_city_v1.png` - vertical dungeon-city background plate for the main menu.
- `resources/art/assetgen/main_menu/main_menu_background_candidate_01.png` - approved assetgen background candidate currently used for the main-menu-only integration test.
- `resources/art/assetgen/main_menu/main_menu_border_outer_candidate_05.png` - candidate_05 sliced outer border from the approved UI sheet.
- `resources/art/assetgen/main_menu/main_menu_button_primary_candidate_05.png` - candidate_05 sliced primary button plate.
- `resources/art/assetgen/main_menu/main_menu_button_secondary_candidate_05.png` - candidate_05 sliced secondary button plate.
- `resources/art/assetgen/main_menu/main_menu_stats_panel_candidate_05.png` - candidate_05 sliced panel used for the menu stats surface.
- `resources/art/assetgen/main_menu/main_menu_icon_profile_candidate_05.png` - candidate_05 sliced profile icon frame.
- `resources/art/assetgen/main_menu/main_menu_icon_settings_candidate_05.png` - candidate_05 sliced settings icon frame.
- `resources/art/assetgen/main_menu/main_menu_icon_achievements_candidate_05.png` - candidate_05 sliced achievements icon frame.
- `resources/art/assetgen/main_menu/main_menu_icon_relic_chest_candidate_05.png` - candidate_05 sliced relic-chest icon frame.
- `resources/art/assetgen/main_menu/main_menu_icon_mastery_progress_candidate_05.png` - candidate_05 sliced mastery-progress icon frame.
- `resources/art/assetgen/main_menu/main_menu_icon_best_run_candidate_05.png` - candidate_05 sliced best-run icon frame.
- `resources/art/assetgen/main_menu/main_menu_icon_profile_candidate_05_semantic.png` - candidate_05 medallion frame with deterministic semantic profile glyph composite.
- `resources/art/assetgen/main_menu/main_menu_icon_settings_candidate_05_semantic.png` - candidate_05 medallion frame with deterministic semantic settings glyph composite.
- `resources/art/assetgen/main_menu/main_menu_icon_achievements_candidate_05_semantic.png` - candidate_05 medallion frame with deterministic semantic achievements glyph composite.
- `resources/art/assetgen/main_menu/main_menu_icon_relic_chest_candidate_05_semantic.png` - candidate_05 medallion frame with deterministic semantic relic-chest glyph composite.
- `resources/art/assetgen/main_menu/main_menu_icon_mastery_progress_candidate_05_semantic.png` - candidate_05 medallion frame with deterministic semantic mastery-progress glyph composite.
- `resources/art/assetgen/main_menu/main_menu_icon_best_run_candidate_05_semantic.png` - candidate_05 medallion frame with deterministic semantic best-run glyph composite.
- `resources/art/assetgen/main_menu/main_menu_stats_panel_candidate_05_frame_only.png` - optional deterministic frame-only variant of the dark slab panel (not wired by default).
- `resources/art/assetgen/main_menu/game_title_logo_candidate_01_alpha.png` - bulk-generation-first logo candidate with deterministic edge-connected dark-background alpha cleanup for main-menu runtime testing.
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

The mapped `backgrounds.main_menu` and `menu.background` paths point to `resources/art/assetgen/main_menu/main_menu_background_candidate_01.png` for the isolated assetgen integration test. The mapped `menu.outer_border`, `menu.button_primary`, `menu.button_secondary`, and `menu.stats_panel` paths point to candidate_05 runtime slices; `menu.menu_icons.*` now points to deterministic semantic candidate_05 composites (`*_semantic.png`) so footer/stat medallions carry meaningful glyphs instead of empty frames. (source: `resources/visual/first_pass_asset_map.json`, `resources/art/assetgen/main_menu/`, `tools/asset_tools/extract_assetgen_main_menu_ui.py`)

The mapped `menu.logo` path now points to `resources/art/assetgen/main_menu/game_title_logo_candidate_01_alpha.png`, generated by `tools/asset_tools/prepare_main_menu_logo_alpha.py` with deterministic edge-connected dark-background removal so the runtime logo uses true alpha. (source: `resources/visual/first_pass_asset_map.json`, `resources/art/assetgen/main_menu/game_title_logo_candidate_01_alpha.png`, `tools/asset_tools/prepare_main_menu_logo_alpha.py`)

### Runtime defect remediation (2026-04-30)

- Resolved logo clipping and menu overlap caused by native texture-size expansion in runtime layout.
- Resolved elemental row/stats/footer overflow caused by unbounded icon minimum sizes.
- Resolved footer panel blowout and bottom text collisions by clamping runtime icon sizes and simplifying bottom label usage.
- Resolution is implemented in runtime scene composition code, not by changing source art dimensions. (source: `scripts/scenes/main_menu.gd`, `docs/test_plan.md`)

### Runtime reference-match pass (2026-04-30)

- Main menu initially used generated `menu.button_primary` and `menu.button_secondary` textures at runtime for action and footer button chrome; this was later replaced by restrained dark `StyleBoxFlat` button styling in the 2026-05-08 readability pass.
- Main menu `StatsPanel` now uses generated `menu.stats_panel` texture at runtime.
- Main menu stats and footer iconography now uses generated `menu.menu_icons` semantic composite mappings at runtime instead of empty candidate_05 medallions or progression-item fallback icons.
- Main menu no longer exposes a visible debug combat button; `Start Run` remains the only functional player-facing action. (source: `scenes/main_menu.tscn`, `scripts/scenes/main_menu.gd`, `docs/test_plan.md`)

### Runtime layout polish (2026-05-08)

- Main-menu runtime view now hides `GenerateLogToggle` while preserving the underlying setting/signal path (`RunState.set_generate_run_log_files_enabled`) so log-export behavior still exists but is not shown in the primary menu UI.
- Main-menu runtime view now hides `ElementRow` (icons/labels) from the menu surface without deleting nodes or removing asset-map mastery icon data.
- Main-menu button stack now uses centered `VBoxContainer` alignment and an updated column rect so `Start Run`, `Continue`, `Collection`, `Settings`, and `Quit` are visually centered in the menu slab after row/toggle removal.
- Main-menu logo rect was enlarged and lowered relative to the prior accepted values (`x=0.03`, `y=0.065`, `w=0.94`, `h=0.16`) to read approximately 1.5x larger in the current runtime presentation pass. (source: `scripts/main_menu/main_menu_view.gd`, `scripts/main_menu/main_menu_controller.gd`)

### Runtime button readability pass (2026-05-08)

- Main-menu action, footer, and profile-overlay action buttons now use shared restrained dark `StyleBoxFlat` treatments in runtime view code instead of candidate_05 `menu.button_primary` and `menu.button_secondary` texture plates.
- `Start Run` remains slightly emphasized with a brighter cool-toned border/text treatment, but without parchment/gold fill.
- Button behavior and disabled-state visuals remain unchanged; only runtime chrome styling was adjusted. (source: `scripts/main_menu/main_menu_view.gd`)

### Checkerboard alpha cleanup (2026-04-30)

- `tools/asset_tools/clean_menu_art.py` removes baked checkerboard pixels from generated menu chrome/icon PNGs and rewrites them with real transparent alpha.
- Cleaned assets include the outer border, primary/secondary button plates, stats triptych panel, and all `main_menu_icon_*` files.
- `scripts/scenes/main_menu.gd` now uses zero texture-slice margins for these highly compressed runtime button/panel plates so the cleaned art remains visible in the current menu layout. (source: `tools/asset_tools/clean_menu_art.py`, `scripts/scenes/main_menu.gd`, `docs/test_plan.md`)

## Important Files

- `resources/art/first_pass/menu/` - generated menu art package.
- `resources/art/assetgen/main_menu/` - approved assetgen main-menu runtime test assets copied out of the governed `assets/` workspace.
- `resources/visual/first_pass_asset_map.json` - JSON map for the new menu art package and the reused mastery icons.
- `docs/main_menu_layout_guide.html` - HTML overlay and slot map for main menu composition/layout planning.
- `docs/main_menu_recreation.html` - HTML visual recreation of the reference menu using the generated art pack.
- `scenes/main_menu.tscn` - authored main menu scene with background/logo zones, textured border, button stack, element row, stats panel, and footer actions.
- `scripts/scenes/main_menu.gd` - main menu host wiring and MVC integration for node bindings and input handlers.
- `scripts/main_menu/main_menu_view.gd` - runtime layout, menu asset-map texture binding, stats panel texture stylebox, and non-textured dark button styling for action/footer/profile buttons.
- `tools/asset_tools/clean_menu_art.py` - menu chrome/icon alpha cleanup utility for generated assets with baked checkerboard backgrounds.
- `tools/asset_tools/extract_assetgen_main_menu_ui.py` - deterministic candidate_05 UI pack slicer for main-menu runtime chrome/icon outputs, edge-connected magenta cleanup, semantic icon compositing, extract report, and preview.
- `tools/asset_tools/prepare_main_menu_logo_alpha.py` - deterministic logo cleanup utility that removes edge-connected dark background pixels from `game_title_logo_candidate_01.png` and writes the runtime alpha logo plus cleanup report.
- `scripts/ui/visual_registry.gd` - still does not expose dedicated menu accessors; main menu currently reads mapped paths directly.

## Open Questions

- Closed for launch readiness: main-menu texture cleanup is not an itch blocker unless ITCH-07 screenshot/page curation identifies it.
- Closed for launch readiness: the menu icon folder split is a future asset-organization cleanup, not an active public-readiness issue.

## Related Pages

- [[file-map]]
- [[features]]
