# Alpha-Fixed Asset Quality Control

Date: 2026-05-08
Scope: `assets/cleanup/alpha_fixed/*.png` plus rejected alpha attempts moved to `assets/rejected/alpha_failed/`

## Purpose

This pass reviews the actual alpha-fixed asset files, not just whether a PNG alpha channel exists. It uses the deterministic cleanup outputs, the full cleanup report, and the white/black/gray/checkerboard contact sheet as evidence.

Evidence:

- `assets/cleanup/alpha_fixed/`
- `assets/qa/transparency_tests/alpha_cleanup_probe_report.full.json`
- `assets/qa/transparency_tests/alpha_cleanup_background_contact_sheet.png`
- `assets/qa/reports/bulk_transparency_qa.md`

## Summary

- Alpha-fixed files reviewed before rejection update: 21
- Alpha-fixed files still active after rejection update: 17
- Adaptive chroma-key real-alpha files added after rejection update: 4
- Usable for deferred QA batch: 11
- Needs targeted visual review before acceptance: 6
- Rejected by human/regeneration pass: 4 asset records
- Needs sprite-pipeline cleanup instead of direct alpha cleanup: 2 source animation sets, not included in `assets/cleanup/alpha_fixed/`
- Runtime integration remains blocked for every asset.

## Usable For Deferred QA Batch

These files have readable silhouettes on white, black, gray, and checkerboard backgrounds, with no obvious fake checkerboard or opaque backdrop in the contact sheet. They still need normal QA, human review, and legal/license review.

- `assets/cleanup/alpha_fixed/equipment_icons_candidate_01_alpha_fixed.png`
- `assets/cleanup/alpha_fixed/intent_icons_candidate_01_alpha_fixed.png`
- `assets/cleanup/alpha_fixed/mastery_icons_candidate_01_alpha_fixed.png`
- `assets/cleanup/alpha_fixed/orb_icons_candidate_01_alpha_fixed.png`
- `assets/cleanup/alpha_fixed/rarity_badges_candidate_01_alpha_fixed.png`
- `assets/cleanup/alpha_fixed/relic_icons_candidate_01_alpha_fixed.png`
- `assets/cleanup/alpha_fixed/shared_hud_chrome_candidate_01_alpha_fixed.png`
- `assets/cleanup/alpha_fixed/shop_ui_pack_candidate_01_alpha_fixed.png`
- `assets/cleanup/alpha_fixed/treasure_chest_icons_candidate_01_alpha_fixed.png`
- `assets/cleanup/alpha_fixed/treasure_chest_icons_candidate_02_alpha_fixed.png`
- `assets/cleanup/alpha_fixed/treasure_chest_icons_candidate_03_alpha_fixed.png`

## Needs Targeted Visual Review

These files have real transparency, but the cleanup may have affected soft glows, dark edges, or component interiors. They should not be promoted until a human visual pass checks them at intended use scale.

- `assets/cleanup/alpha_fixed/combat_ui_chrome_pack_candidate_01_alpha_fixed.png`
  - Risk: thin dark chrome edges may need close inspection on light backgrounds.
- `assets/cleanup/alpha_fixed/main_menu_ui_pack_candidate_01_alpha_fixed.png`
  - Risk: dark UI panels on a dark original background may have edge loss.
- `assets/cleanup/alpha_fixed/result_screen_ui_pack_candidate_01_alpha_fixed.png`
  - Risk: source remains a concept/component sheet, not separated runtime-ready UI chrome.
- `assets/cleanup/alpha_fixed/shop_transaction_vfx_candidate_01_alpha_fixed.png`
  - Risk: VFX glow/coin trails may have lost subtle partial-alpha detail.
- `assets/cleanup/alpha_fixed/tutorial_onboarding_ui_pack_candidate_01_alpha_fixed.png`
  - Risk: dark background cleanup may affect panel borders and small symbols.
- `assets/cleanup/alpha_fixed/unlock_achievement_vfx_candidate_01_alpha_fixed.png`
  - Risk: celebratory glows should be checked against both light and dark UI surfaces.

## Rejected / Requires True-Alpha Regeneration

The human rejected these deterministic cleanup outputs as unusable, and the follow-up `candidate_02` regeneration attempts via built-in imagegen also failed real-alpha generation. Pixel probes on the `candidate_02` PNGs returned `min_alpha=255`, `max_alpha=255`, `alpha_zero=0`, and `alpha_partial=0`; visual inspection showed baked checkerboard/false transparency. The rejected files were moved to `assets/rejected/alpha_failed/` and removed from active candidate paths.

- `board_orb_clear_vfx`
- `consumable_icons`
- `enemy_attack_vfx`
- `mastery_vfx`

## Adaptive Chroma-Key Outputs Added

After documenting the chroma-key fallback, `candidate_03_chroma_key` opaque keyed sources were generated and processed with `assets/qa/transparency_tests/adaptive_border_extract.py`. The extracted RGBA files have real alpha and probe warnings are empty in `assets/qa/transparency_tests/adaptive_border_extract_report.candidate_03.json`. These outputs are staged for deferred QA, not approved:

- `assets/cleanup/chroma_keyed_adaptive/board_orb_clear_vfx_candidate_03_adaptive_alpha.png`
- `assets/cleanup/chroma_keyed_adaptive/consumable_icons_candidate_03_adaptive_alpha.png`
- `assets/cleanup/chroma_keyed_adaptive/enemy_attack_vfx_candidate_03_adaptive_alpha.png`
- `assets/cleanup/chroma_keyed_adaptive/mastery_vfx_candidate_03_adaptive_alpha.png`

## Still Needs Sprite-Pipeline Cleanup

These are source animation sheets and should not be treated as final transparent runtime assets yet:

- `hero_animation_set`
- `enemy_animation_set`

They need sprite-pipeline normalization/extraction before frame-level alpha QA.

## Gate Outcome

The remaining active alpha-fixed directory and adaptive chroma-key outputs contain real-transparent PNG assets. The usable group can proceed into the deferred QA batch. The targeted-review group needs visual inspection and possible cleanup iteration before acceptance. No asset is approved or integrated by this pass.
