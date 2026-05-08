# Adaptive Chroma-Key Quality Control

Date: 2026-05-08
Scope: `assets/cleanup/chroma_keyed_adaptive_all/*candidate_04_adaptive_alpha.png`

## Purpose

This pass records the human visual review outcome for the 21 regenerated chroma-key fallback outputs after adaptive connected-border extraction.

Evidence:

- `assets/qa/transparency_tests/adaptive_border_extract_report.candidate_04.full.json`
- `assets/qa/transparency_tests/adaptive_candidate_04_contact_sheet.png`
- `assets/cleanup/chroma_keyed_adaptive_all/`
- `assets/index.html`
- `assets/qa/reports/bulk_transparency_qa.md`

## Summary

- Adaptive RGBA files reviewed: 21
- Alpha probe failures: 0
- Human accepted as fine to proceed from deferred QA: 16
- Needs another pass: 3
- Can proceed to sprite-pipeline normalization: 2
- Runtime integration remains blocked for every asset.

## Fine To Proceed From Deferred QA

The human accepted these outputs as fine for the next review gate. They still need legal/license review and final approval before integration.

- `assets/cleanup/chroma_keyed_adaptive_all/board_orb_clear_vfx_candidate_04_adaptive_alpha.png`
- `assets/cleanup/chroma_keyed_adaptive_all/combat_ui_chrome_pack_candidate_04_adaptive_alpha.png`
- `assets/cleanup/chroma_keyed_adaptive_all/consumable_icons_candidate_04_adaptive_alpha.png`
- `assets/cleanup/chroma_keyed_adaptive_all/enemy_attack_vfx_candidate_04_adaptive_alpha.png`
- `assets/cleanup/chroma_keyed_adaptive_all/equipment_icons_candidate_04_adaptive_alpha.png`
- `assets/cleanup/chroma_keyed_adaptive_all/intent_icons_candidate_04_adaptive_alpha.png`
- `assets/cleanup/chroma_keyed_adaptive_all/mastery_icons_candidate_04_adaptive_alpha.png`
- `assets/cleanup/chroma_keyed_adaptive_all/mastery_vfx_candidate_04_adaptive_alpha.png`
- `assets/cleanup/chroma_keyed_adaptive_all/orb_icons_candidate_04_adaptive_alpha.png`
- `assets/cleanup/chroma_keyed_adaptive_all/rarity_badges_candidate_04_adaptive_alpha.png`
- `assets/cleanup/chroma_keyed_adaptive_all/relic_icons_candidate_04_adaptive_alpha.png`
- `assets/cleanup/chroma_keyed_adaptive_all/result_screen_ui_pack_candidate_04_adaptive_alpha.png`
- `assets/cleanup/chroma_keyed_adaptive_all/shop_transaction_vfx_candidate_04_adaptive_alpha.png`
- `assets/cleanup/chroma_keyed_adaptive_all/shop_ui_pack_candidate_04_adaptive_alpha.png`
- `assets/cleanup/chroma_keyed_adaptive_all/treasure_chest_icons_candidate_04_adaptive_alpha.png`
- `assets/cleanup/chroma_keyed_adaptive_all/unlock_achievement_vfx_candidate_04_adaptive_alpha.png`

## Candidate 05 UI Retry Outcome

The human reviewed the candidate_05 retry outputs. Two are accepted for the next review gate, while one still needs another pass.

- Accepted:
  - `assets/cleanup/chroma_keyed_adaptive_ui_retry/main_menu_ui_pack_candidate_05_adaptive_alpha.png`
  - `assets/cleanup/chroma_keyed_adaptive_ui_retry/shared_hud_chrome_candidate_05_adaptive_alpha.png`
- Needs another pass:
  - `assets/cleanup/chroma_keyed_adaptive_ui_retry/tutorial_onboarding_ui_pack_candidate_05_adaptive_alpha.png`

Reason: `tutorial_onboarding_ui_pack` still has one magenta artifact.

## Previous Candidate 04 UI Failures

These earlier candidate_04 outputs remain failed evidence and should not be promoted:

- `assets/cleanup/chroma_keyed_adaptive_all/main_menu_ui_pack_candidate_04_adaptive_alpha.png`
- `assets/cleanup/chroma_keyed_adaptive_all/shared_hud_chrome_candidate_04_adaptive_alpha.png`
- `assets/cleanup/chroma_keyed_adaptive_all/tutorial_onboarding_ui_pack_candidate_04_adaptive_alpha.png`

## Sprite-Pipeline Outcome

Deterministic 4x2 slicing produced raw frames, 512x512 normalized frames, preview strips, and contact sheets under `assets/sprite_pipeline/candidate_04/`. The human reviewed both sprite previews and rejected them as bad.

- `assets/sprite_pipeline/candidate_04/hero_animation_set/preview_strip_8col.png`
- `assets/sprite_pipeline/candidate_04/enemy_animation_set/preview_strip_8col.png`

## Metadata Outcome

- Fine assets: `qa_status = review_pending`, `review_status = human_visual_review_passed_pending_legal`
- Accepted candidate_05 UI retries: `qa_status = review_pending`, `review_status = human_visual_review_passed_pending_legal`
- `tutorial_onboarding_ui_pack`: `qa_status = cleanup_required`, `review_status = needs_another_visual_pass_candidate_05`
- Animation sheets: `qa_status = cleanup_required`, `review_status = sprite_pipeline_visual_review_failed`

## Gate Outcome

No asset is approved or integrated by this pass. Fine assets and the two accepted candidate_05 UI retries can move to legal/final review. `tutorial_onboarding_ui_pack`, `hero_animation_set`, and `enemy_animation_set` needed another pass after this review.

## Candidate 06 Follow-Up

The remaining three blocked assets were regenerated with the transparency fallback:

- `tutorial_onboarding_ui_pack`: `assets/generated/candidates/bulk-generation-first/tutorial_onboarding_ui_pack_candidate_06_chroma_key.png` -> `assets/cleanup/chroma_keyed_adaptive_candidate_06/tutorial_onboarding_ui_pack_candidate_06_adaptive_alpha.png`
- `hero_animation_set`: `assets/generated/candidates/bulk-generation-first/hero_animation_set_candidate_06_chroma_key.png` -> `assets/cleanup/chroma_keyed_adaptive_candidate_06/hero_animation_set_candidate_06_adaptive_alpha.png` -> `assets/sprite_pipeline/candidate_06/hero_animation_set/preview_strip_8col.png`
- `enemy_animation_set`: `assets/generated/candidates/bulk-generation-first/enemy_animation_set_candidate_06_chroma_key.png` -> `assets/cleanup/chroma_keyed_adaptive_candidate_06/enemy_animation_set_candidate_06_adaptive_alpha.png` -> `assets/sprite_pipeline/candidate_06/enemy_animation_set/preview_strip_8col.png`

The extraction report records no warnings for candidate_06. `tutorial_onboarding_ui_pack` remains on candidate_06 for review. The animation sets were then refined again: `hero_animation_set` now uses candidate_07, and `enemy_animation_set` now uses candidate_08 with component-based sprite slicing to avoid split-frame artifacts.

After soft-key extraction and sprite-preview cleanup, the human accepted all three remaining outputs as good. On 2026-05-08, the human approved the assetgen batch for integration. Runtime integration has not been performed yet.
