# Meta unlock and achievement toast VFX

Asset ID: unlock_achievement_vfx
Type: vfx_set
Group: vfx - Gameplay VFX
Wave: wave-04-remaining-production-assets
Inventory status: missing

## Purpose

Prepare production candidate assets for Meta unlock and achievement toast VFX based on assets.json while preserving the assetgen approval workflow.

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
- Metadata record required: assets/generated/metadata/records/unlock_achievement_vfx.json.
- QA report target: assets/qa/reports/unlock_achievement_vfx.qa.md.

## Prompt Starter

Use case: stylized-concept
Asset type: vfx_set
Primary request: Create production candidate art for Meta unlock and achievement toast VFX in Orbwalker, a fantasy match-3 roguelike.
Constraints: no watermark, no copyrighted characters, no casino imagery, no gore, no unapproved text, no baked checkerboard, mobile-readable silhouette.
