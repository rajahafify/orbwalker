# Combat chrome texture pack

Asset ID: combat_ui_chrome_pack
Type: ui_pack
Group: ui_chrome - UI Chrome, HUD Frames, Buttons, Panels, And Slots
Wave: wave-04-remaining-production-assets
Inventory status: first_pass_exists

## Purpose

Prepare production candidate assets for Combat chrome texture pack based on assets.json while preserving the assetgen approval workflow.

## Current References

- res://resources/art/first_pass/derived/combat_ui/combat_top_bar_frame.png
- res://resources/art/first_pass/derived/combat_ui/combat_enemy_panel_frame.png
- res://resources/art/first_pass/derived/combat_ui/combat_board_frame.png
- res://resources/art/first_pass/derived/combat_ui/combat_mastery_rail_frame.png
- res://resources/art/first_pass/derived/combat_ui/combat_player_hud_rail.png
- res://resources/art/first_pass/derived/combat_ui/combat_player_vitals_frame.png
- res://resources/art/first_pass/derived/combat_ui/combat_equipment_rail_frame.png
- res://resources/art/first_pass/derived/combat_ui/combat_consumables_rail_frame.png
- res://resources/art/first_pass/derived/combat_ui/combat_slot_frame_empty.png
- res://resources/art/first_pass/derived/combat_ui/combat_slot_frame_filled.png
- res://resources/art/first_pass/derived/combat_ui/combat_timer_track.png
- res://resources/art/first_pass/derived/combat_ui/combat_timer_center_marker.png
- res://resources/art/first_pass/derived/combat_ui/combat_divider_h.png
- res://resources/art/first_pass/derived/combat_ui/combat_corner_ornament.png
- res://resources/art/first_pass/derived/combat_ui/combat_backdrop_scrim.png

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
- Metadata record required: assets/generated/metadata/records/combat_ui_chrome_pack.json.
- QA report target: assets/qa/reports/combat_ui_chrome_pack.qa.md.

## Prompt Starter

Use case: stylized-concept
Asset type: ui_pack
Primary request: Create production candidate art for Combat chrome texture pack in Orbwalker, a fantasy match-3 roguelike.
Constraints: no watermark, no copyrighted characters, no casino imagery, no gore, no unapproved text, no baked checkerboard, mobile-readable silhouette.
