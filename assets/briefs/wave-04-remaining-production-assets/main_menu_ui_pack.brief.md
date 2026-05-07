# Main menu buttons, border, stats panel, and menu icons

Asset ID: main_menu_ui_pack
Type: ui_pack
Group: ui_chrome - UI Chrome, HUD Frames, Buttons, Panels, And Slots
Wave: wave-04-remaining-production-assets
Inventory status: first_pass_exists

## Purpose

Prepare production candidate assets for Main menu buttons, border, stats panel, and menu icons based on assets.json while preserving the assetgen approval workflow.

## Current References

- res://resources/art/first_pass/menu/main_menu_border_outer_v1.png
- res://resources/art/first_pass/menu/main_menu_button_primary_v1.png
- res://resources/art/first_pass/menu/main_menu_button_secondary_v1.png
- res://resources/art/first_pass/menu/main_menu_stats_triptych_panel_v1.png
- res://resources/art/first_pass/menu/main_menu_icon_relic_chest_v1.png
- res://resources/art/first_pass/menu/main_menu_icon_mastery_progress_v1.png
- res://resources/art/first_pass/menu/main_menu_icon_best_run_demon_v1.png
- res://resources/art/first_pass/menu/main_menu_icon_profile_v1.png
- res://resources/art/first_pass/menu/main_menu_icon_achievements_v1.png
- res://resources/art/first_pass/menu/main_menu_icon_settings_v1.png

## Requirements

- Follow assets/art_bible/style.md.
- Use the built-in imagegen path for image candidates when this is visual art.
- Audio entries are specification-only in this pass; do not generate or replace audio files.
- Do not overwrite resources/art/first_pass/ or any runtime path.
- Keep runtime integration blocked until QA, human review, legal/license review, and explicit approval pass.

## Technical Target

- Export format: PNG for visual candidates unless a later brief says otherwise.
- Transparent background: true for isolated assets unless this brief is later revised to a full-background composition.
- Embedded text: none unless separately approved.
- Metadata record required: assets/generated/metadata/records/main_menu_ui_pack.json.
- QA report target: assets/qa/reports/main_menu_ui_pack.qa.md.

## Prompt Starter

Use case: stylized-concept
Asset type: ui_pack
Primary request: Create production candidate art for Main menu buttons, border, stats panel, and menu icons in Orbwalker, a fantasy match-3 roguelike.
Constraints: no watermark, no copyrighted characters, no casino imagery, no gore, no unapproved text, no baked checkerboard, mobile-readable silhouette.
