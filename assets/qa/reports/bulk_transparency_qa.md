# Bulk Transparency QA Report

Date: 2026-05-08
Mode: bulk_generation_first deferred QA documentation pass

## Scope

This pass documents transparency outcomes for generated candidate PNGs using existing probe evidence at `assets/qa/transparency_tests/transparency_probe_current.json`.

Out of scope:
- New image generation
- Runtime resource integration
- Non-image assets (audio/screenshot/video placeholders)

## Evidence Inputs

- `resources/assetgen.workflow.md`
- `assets/generated/metadata/assets.json`
- `assets/qa/checklists/transparency_checklist.md`
- `assets/qa/transparency_tests/transparency_probe_current.json`
- Existing Wave 1 QA reports under `assets/qa/reports/`

## Coverage Summary

- Generated asset records with candidate PNGs: 38
- Alpha-sensitive assets checked (UI/VFX/icon sheets + result_screen_ui_pack + sprite-source sheets): 21
- Alpha-sensitive PNG files checked from probe: 24
- Alpha-sensitive files with real alpha: 1
- Asset with real alpha evidence: `treasure_chest_icons` cleanup file `assets/cleanup/treasure_chest_icons_candidate_03_alpha_cleanup.png`
- Alpha-sensitive assets marked `cleanup_required`: 21
- Generated opaque/non-alpha-sensitive assets kept non-failed: 17

## Findings

### 1) Alpha-sensitive candidates are mostly RGB/no real alpha

The probe reports `Format24bppRgb` and zero transparent/partial-alpha samples for almost all alpha-sensitive files.

Affected alpha-sensitive assets marked `cleanup_required`:

- `board_orb_clear_vfx`
- `combat_ui_chrome_pack`
- `consumable_icons`
- `enemy_attack_vfx`
- `equipment_icons`
- `intent_icons`
- `main_menu_ui_pack`
- `mastery_icons`
- `mastery_vfx`
- `orb_icons`
- `rarity_badges`
- `relic_icons`
- `result_screen_ui_pack`
- `shared_hud_chrome`
- `shop_transaction_vfx`
- `shop_ui_pack`
- `treasure_chest_icons`
- `tutorial_onboarding_ui_pack`
- `unlock_achievement_vfx`
- `hero_animation_set`
- `enemy_animation_set`

### 2) Treasure chest cleanup candidate is the only current real-alpha file

- Generated `treasure_chest_icons` candidates remain RGB/opaque.
- Cleanup file `assets/cleanup/treasure_chest_icons_candidate_03_alpha_cleanup.png` has real alpha (`Format32bppArgb`, transparent sample hits present).
- Record remains `cleanup_required` because the pack is still mixed and not production-ready.

### 3) Sprite source sheets are explicitly deferred to sprite-pipeline cleanup

`hero_animation_set` and `enemy_animation_set` remain blocked with transparency state set to sprite-pipeline deferral because current source sheets are RGB and need normalization/extraction cleanup in the sprite-pipeline stage.

### 4) Opaque candidates are not failed for alpha

Opaque/background/key-art style candidates are not marked failed only for lacking alpha in this pass; they remain in deferred bulk QA state unless they are in the alpha-sensitive set above.

## Status Updates Applied

- Per-record metadata updated for affected records:
  - `qa_status: cleanup_required`
  - `alpha_type` and `transparent_background` set to explicit transparency outcomes
  - Notes appended with deferred transparency QA findings
- `assets/qa/reports/qa_status_manifest.json` updated to reflect cleanup-required states for alpha-sensitive records.
- `assets/approved/status_manifest.json` updated so cleanup-required records stay blocked (`blocked_cleanup_required`).
- `assets/generated/metadata/assets.json` regenerated from per-record metadata.

## Gate Outcome

Runtime integration remains blocked. Deferred transparency QA confirms that the current bulk candidates still require cleanup/sprite-pipeline follow-up before review and approval can proceed for alpha-sensitive records.
