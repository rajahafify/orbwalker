# Treasure chest icons

Asset ID: treasure_chest_icons
Type: icon_set
Group: core_gameplay_icons - Orbs, Mastery, Intent, Rarity, Equipment, Consumable, Relic, And Treasure Chest Icons
Wave: wave-01-public-demo-core
Inventory status: placeholder_or_reused

## Purpose

Prepare production candidate assets for Treasure chest icons based on assets.json while preserving the assetgen approval workflow.

## Current References

- None recorded

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
- Metadata record required: assets/generated/metadata/records/treasure_chest_icons.json.
- QA report target: assets/qa/reports/treasure_chest_icons.qa.md.

## Prompt Starter

Use case: stylized-concept
Asset type: icon_set
Primary request: Create production candidate art for Treasure chest icons in Orbwalker, a fantasy match-3 roguelike.
Constraints: no watermark, no copyrighted characters, no casino imagery, no gore, no unapproved text, no baked checkerboard, mobile-readable silhouette.
