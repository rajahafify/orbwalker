# Shared player HUD, HP bars, slot frames, and mastery panels

Asset ID: shared_hud_chrome
Type: ui_pack
Group: ui_chrome - UI Chrome, HUD Frames, Buttons, Panels, And Slots
Wave: wave-04-remaining-production-assets
Inventory status: first_pass_exists

## Purpose

Prepare production candidate assets for Shared player HUD, HP bars, slot frames, and mastery panels based on assets.json while preserving the assetgen approval workflow.

## Current References

- res://resources/art/first_pass/derived/hud/hp_bar_frame.png
- res://resources/art/first_pass/derived/hud/hp_bar_fill.png
- res://resources/art/first_pass/derived/hud/enemy_hp_bar_frame.png
- res://resources/art/first_pass/derived/hud/enemy_hp_bar_fill.png
- res://resources/art/first_pass/derived/hud/combo_badge_frame.png
- res://resources/art/first_pass/derived/ui_chrome/panel_frame.png
- res://resources/art/first_pass/derived/ui_chrome/slot_frame_equipment.png
- res://resources/art/first_pass/derived/ui_chrome/slot_frame_consumable.png
- res://resources/art/first_pass/derived/ui_chrome/mastery_panel_frame.png
- res://resources/art/first_pass/derived/ui_chrome/mastery_preview_panel_frame.png

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
- Metadata record required: assets/generated/metadata/records/shared_hud_chrome.json.
- QA report target: assets/qa/reports/shared_hud_chrome.qa.md.

## Prompt Starter

Use case: stylized-concept
Asset type: ui_pack
Primary request: Create production candidate art for Shared player HUD, HP bars, slot frames, and mastery panels in Orbwalker, a fantasy match-3 roguelike.
Constraints: no watermark, no copyrighted characters, no casino imagery, no gore, no unapproved text, no baked checkerboard, mobile-readable silhouette.
