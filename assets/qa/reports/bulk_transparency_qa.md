# Bulk Transparency QA Report

Date: 2026-05-08
Mode: bulk_generation_first deferred QA documentation pass

## Scope

This pass documents transparency outcomes for generated candidate PNGs using probe evidence from the original transparency probe, deterministic alpha cleanup, and the full chroma-key fallback regeneration.

Out of scope:
- Runtime resource integration
- Non-image assets (audio/screenshot/video placeholders)
- Approval, legal/license review, and final human acceptance

## Evidence Inputs

- `resources/assetgen.workflow.md`
- `assets/generated/metadata/assets.json`
- `assets/qa/checklists/transparency_checklist.md`
- `assets/qa/transparency_tests/transparency_probe_current.json`
- `assets/qa/transparency_tests/alpha_cleanup_probe_report.full.json`
- `assets/qa/transparency_tests/adaptive_border_extract_report.candidate_04.full.json`
- `assets/qa/transparency_tests/adaptive_candidate_04_contact_sheet.png`
- `assets/qa/transparency_tests/adaptive_border_extract_report.candidate_06.remaining.json`
- `assets/qa/reports/sprite_pipeline_candidate_06.md`
- `assets/qa/transparency_tests/adaptive_border_extract_report.candidate_07.animations.json`
- `assets/qa/transparency_tests/adaptive_border_extract_report.candidate_08.enemy.json`
- `assets/qa/reports/sprite_pipeline_candidate_07_08.md`
- `assets/qa/reports/adaptive_chroma_key_quality_control.md`

## Coverage Summary

- Generated asset records with candidate PNGs: 38
- Alpha-sensitive assets checked (UI/VFX/icon sheets + result_screen_ui_pack + sprite-source sheets): 21
- Deterministic alpha cleanup outputs generated before chroma-key fallback: 21
- Chroma-key fallback source candidates generated: 21
- Adaptive chroma-key RGBA outputs generated: 21
- Adaptive chroma-key extraction warnings: 0
- Candidate_06 follow-up assets regenerated with transparency fallback: 3
- Candidate_06 extraction warnings: 0
- Alpha-sensitive assets visually accepted for next review gate: 18
- Alpha-sensitive assets still `cleanup_required`: 3
- Generated opaque/non-alpha-sensitive assets kept non-failed: 17

## Findings

### 1) Full Chroma-Key Fallback Outputs Are Recorded

The documented chroma-key fallback was applied to the full 21-record alpha-sensitive set. Built-in imagegen produced `candidate_04_chroma_key` opaque keyed sources, and `assets/qa/transparency_tests/adaptive_border_extract.py` produced extracted RGBA outputs under `assets/cleanup/chroma_keyed_adaptive_all/`.

`assets/qa/transparency_tests/adaptive_border_extract_report.candidate_04.full.json` reports `alpha_minmax: [0, 255]` and `warnings: []` for every extracted output. `assets/qa/transparency_tests/adaptive_candidate_04_contact_sheet.png` composites the outputs on white, black, gray, and checkerboard backgrounds for visual review.

`assets/qa/reports/adaptive_chroma_key_quality_control.md` records the current human visual review split: 16 candidate_04 outputs accepted as fine to proceed from deferred QA, 2 candidate_05 UI retries accepted as good, and 3 assets still requiring another pass.

Active adaptive chroma-key output records reviewed by the human:

- `board_orb_clear_vfx`
- `combat_ui_chrome_pack`
- `consumable_icons`
- `enemy_animation_set`
- `enemy_attack_vfx`
- `equipment_icons`
- `hero_animation_set`
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

### 2) Prior Failed Alpha Attempts Remain Rejected Evidence

The human rejected the deterministic alpha-fixed files for `board_orb_clear_vfx`, `consumable_icons`, `enemy_attack_vfx`, and `mastery_vfx` as unusable. A follow-up multi-agent true-alpha prompt pass produced `candidate_02` attempts, but all four PNGs were fully opaque with baked checkerboard/false transparency. Those rejected files remain under `assets/rejected/alpha_failed/`.

The later `candidate_03` chroma-key pass produced valid adaptive outputs for the same four records, but the current active alpha-sensitive set now points at the regenerated `candidate_04` adaptive outputs for consistency across the batch.

### 3) Animation Source Sheets Failed Sprite-Pipeline Visual Review

`hero_animation_set` and `enemy_animation_set` have adaptive chroma-key RGBA source-sheet candidates and deterministic sprite-pipeline preview strips under `assets/sprite_pipeline/candidate_04/`. The human rejected both previews as bad, so both records remain blocked pending source/animation rework rather than promotion.

### 4) Opaque Candidates Are Not Failed For Alpha

Opaque/background/key-art style candidates are not marked failed only for lacking alpha in this pass; they remain in deferred bulk QA state unless they are in the alpha-sensitive set above.

## Status Updates Applied

- Per-record metadata updated for affected records:
  - Added active adaptive chroma-key extracted RGBA outputs under `assets/cleanup/chroma_keyed_adaptive_all/`
  - Kept the original `candidate_01` paths as source history
  - Left opaque keyed `candidate_04_chroma_key` sources as trace evidence, not active candidates
- `qa_status: review_pending` for 16 human-accepted candidate_04 records
- `qa_status: review_pending` for accepted candidate_05 UI retries of `main_menu_ui_pack` and `shared_hud_chrome`
- `qa_status: cleanup_required` for `tutorial_onboarding_ui_pack` because candidate_05 still has one magenta artifact
- `qa_status: cleanup_required` for sprite-pipeline-normalized `hero_animation_set` and `enemy_animation_set` because both previews failed visual review
  - `alpha_type` and `transparent_background` set to adaptive chroma-key real-alpha pending-QA states
  - Notes updated to keep approval/integration blocked pending deferred QA and human/legal review
- `assets/qa/reports/qa_status_manifest.json` updated to reflect the human review decisions.
- `assets/approved/status_manifest.json` updated so all 21 alpha-sensitive records remain blocked pending rework, sprite-pipeline, or legal/final approval.
- `assets/generated/metadata/assets.json` regenerated from per-record metadata.

## Gate Outcome

Runtime integration remains blocked. Human-accepted adaptive chroma-key outputs are staged for legal/final review, while `tutorial_onboarding_ui_pack`, `hero_animation_set`, and `enemy_animation_set` remain blocked pending rework.

## Candidate 06 Follow-Up

The remaining three blocked assets were regenerated as candidate_06 using the same transparency fallback. The animation sheets also used the fallback before sprite normalization, so `assets/sprite_pipeline/candidate_06/` starts from extracted RGBA sources rather than opaque keyed sources.

- `tutorial_onboarding_ui_pack`: `assets/cleanup/chroma_keyed_adaptive_candidate_06/tutorial_onboarding_ui_pack_candidate_06_adaptive_alpha.png`
- `hero_animation_set`: superseded by `assets/sprite_pipeline/candidate_07/hero_animation_set/preview_strip_8col.png`
- `enemy_animation_set`: superseded by `assets/sprite_pipeline/candidate_08_component/enemy_animation_set/preview_strip_8col.png`

`tutorial_onboarding_ui_pack` remains on candidate_06. The animation sets were refined again after candidate_06: `hero_animation_set` now uses candidate_07, and `enemy_animation_set` now uses candidate_08 with component-based slicing from the extracted alpha sheet. After soft-key extraction and sprite-preview cleanup, the human accepted all three latest outputs as good. They remain blocked from integration pending legal/license review and final approval.
