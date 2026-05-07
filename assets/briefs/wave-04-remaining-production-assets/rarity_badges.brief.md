# Common/uncommon/rare rarity badges

Asset ID: rarity_badges
Type: rarity_badge_set
Group: core_gameplay_icons - Orbs, Mastery, Intent, Rarity, Equipment, Consumable, Relic, And Treasure Chest Icons
Wave: wave-04-remaining-production-assets
Inventory status: first_pass_exists

## Purpose

Prepare production candidate assets for Common/uncommon/rare rarity badges based on assets.json while preserving the assetgen approval workflow.

## Current References

- res://resources/art/first_pass/derived/hud/rarity_common.png
- res://resources/art/first_pass/derived/hud/rarity_uncommon.png
- res://resources/art/first_pass/derived/hud/rarity_rare.png
- res://resources/art/first_pass/sheets/rarity_badge_set_v1.png

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
- Metadata record required: assets/generated/metadata/records/rarity_badges.json.
- QA report target: assets/qa/reports/rarity_badges.qa.md.

## Prompt Starter

Use case: stylized-concept
Asset type: rarity_badge_set
Primary request: Create production candidate art for Common/uncommon/rare rarity badges in Orbwalker, a fantasy match-3 roguelike.
Constraints: no watermark, no copyrighted characters, no casino imagery, no gore, no unapproved text, no baked checkerboard, mobile-readable silhouette.
