# Dungeon combat background

Asset ID: combat_background
Type: background
Group: screens - Screen Backgrounds And Scene Art
Wave: wave-04-remaining-production-assets
Inventory status: first_pass_exists

## Purpose

Prepare production candidate assets for Dungeon combat background based on assets.json while preserving the assetgen approval workflow.

## Current References

- res://resources/art/first_pass/backgrounds/combat_bg_dungeon_01.png
- res://resources/art/first_pass/derived/combat_layers/generated_cavern_dungeon_bg_v1.png

## Requirements

- Follow assets/art_bible/style.md.
- Use the built-in imagegen path for image candidates when this is visual art.
- Audio entries are specification-only in this pass; do not generate or replace audio files.
- Do not overwrite resources/art/first_pass/ or any runtime path.
- Keep runtime integration blocked until QA, human review, legal/license review, and explicit approval pass.

## Technical Target

- Export format: PNG for visual candidates unless a later brief says otherwise.
- Transparent background: false unless generated as a cutout.
- Embedded text: none unless separately approved.
- Metadata record required: assets/generated/metadata/records/combat_background.json.
- QA report target: assets/qa/reports/combat_background.qa.md.

## Prompt Starter

Use case: stylized-concept
Asset type: background
Primary request: Create production candidate art for Dungeon combat background in Orbwalker, a fantasy match-3 roguelike.
Constraints: no watermark, no copyrighted characters, no casino imagery, no gore, no unapproved text, no baked checkerboard, mobile-readable silhouette.
