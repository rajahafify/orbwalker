# Shop music loop

Asset ID: music_shop
Type: music
Group: audio - Music And Sound Effects
Wave: wave-04-remaining-production-assets
Inventory status: first_pass_exists

## Purpose

Prepare production candidate assets for Shop music loop based on assets.json while preserving the assetgen approval workflow.

## Current References

- res://resources/audio/music/shop.wav
- res://resources/audio/raw_music/shop.wav.bin
- res://raw/shop.mid

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
- Metadata record required: assets/generated/metadata/records/music_shop.json.
- QA report target: assets/qa/reports/music_shop.qa.md.

## Prompt Starter

Use case: stylized-concept
Asset type: music
Primary request: Create production candidate art for Shop music loop in Orbwalker, a fantasy match-3 roguelike.
Constraints: no watermark, no copyrighted characters, no casino imagery, no gore, no unapproved text, no baked checkerboard, mobile-readable silhouette.
