# Wide enemy encounter stage/banner art

Asset ID: combat_enemy_stage_art
Type: combat_stage_set
Group: characters - Hero, Enemy, Boss, And Merchant Character Art
Wave: wave-02-runtime-art-alignment
Inventory status: first_pass_exists

## Purpose

Prepare production candidate assets for Wide enemy encounter stage/banner art based on assets.json while preserving the assetgen approval workflow.

## Current References

- res://resources/art/first_pass/derived/combat_ui/combat_stage_cavern_striker.png
- res://resources/art/first_pass/derived/combat_ui/combat_stage_cavern_defender.png
- res://resources/art/first_pass/derived/combat_ui/combat_stage_ash_hunter.png
- res://resources/art/first_pass/derived/combat_ui/combat_stage_ruin_lancer.png
- res://resources/art/first_pass/derived/combat_ui/combat_stage_vault_executioner.png
- res://resources/art/first_pass/derived/combat_ui/combat_stage_goldbound_keeper.png
- res://resources/art/first_pass/derived/combat_ui/combat_stage_iron_gate.png
- res://resources/art/first_pass/derived/combat_ui/combat_stage_burning_knight.png
- res://resources/art/first_pass/derived/combat_ui/combat_stage_prism_warden.png
- res://resources/art/first_pass/derived/combat_ui/combat_stage_fallback.png

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
- Metadata record required: assets/generated/metadata/records/combat_enemy_stage_art.json.
- QA report target: assets/qa/reports/combat_enemy_stage_art.qa.md.

## Prompt Starter

Use case: stylized-concept
Asset type: combat_stage_set
Primary request: Create production candidate art for Wide enemy encounter stage/banner art in Orbwalker, a fantasy match-3 roguelike.
Constraints: no watermark, no copyrighted characters, no casino imagery, no gore, no unapproved text, no baked checkerboard, mobile-readable silhouette.
