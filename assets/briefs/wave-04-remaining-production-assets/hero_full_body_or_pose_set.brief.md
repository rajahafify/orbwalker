# Orbwalker full-body/key pose set

Asset ID: hero_full_body_or_pose_set
Type: character_pose
Group: characters - Hero, Enemy, Boss, And Merchant Character Art
Wave: wave-04-remaining-production-assets
Inventory status: missing

## Purpose

Prepare production candidate assets for Orbwalker full-body/key pose set based on assets.json while preserving the assetgen approval workflow.

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
- Transparent background: false unless generated as a cutout.
- Embedded text: none unless separately approved.
- Metadata record required: assets/generated/metadata/records/hero_full_body_or_pose_set.json.
- QA report target: assets/qa/reports/hero_full_body_or_pose_set.qa.md.

## Prompt Starter

Use case: stylized-concept
Asset type: character_pose
Primary request: Create production candidate art for Orbwalker full-body/key pose set in Orbwalker, a fantasy match-3 roguelike.
Constraints: no watermark, no copyrighted characters, no casino imagery, no gore, no unapproved text, no baked checkerboard, mobile-readable silhouette.
