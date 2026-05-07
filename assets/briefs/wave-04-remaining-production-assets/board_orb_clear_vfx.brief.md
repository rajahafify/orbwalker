# Orb clear, cascade, and combo VFX

Asset ID: board_orb_clear_vfx
Type: vfx_set
Group: vfx - Gameplay VFX
Wave: wave-04-remaining-production-assets
Inventory status: first_pass_exists

## Purpose

Prepare production candidate assets for Orb clear, cascade, and combo VFX based on assets.json while preserving the assetgen approval workflow.

## Current References

- res://resources/art/first_pass/vfx/vfx_sprite_sheet_v1.png

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
- Metadata record required: assets/generated/metadata/records/board_orb_clear_vfx.json.
- QA report target: assets/qa/reports/board_orb_clear_vfx.qa.md.

## Prompt Starter

Use case: stylized-concept
Asset type: vfx_set
Primary request: Create production candidate art for Orb clear, cascade, and combo VFX in Orbwalker, a fantasy match-3 roguelike.
Constraints: no watermark, no copyrighted characters, no casino imagery, no gore, no unapproved text, no baked checkerboard, mobile-readable silhouette.
