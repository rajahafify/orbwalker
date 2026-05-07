# Sprite Pipeline Candidate 07/08 Normalization

Date: 2026-05-08  
Scope: `hero_animation_set`, `enemy_animation_set`

## Inputs

- Hero: `assets/generated/candidates/bulk-generation-first/hero_animation_set_candidate_07_chroma_key.png`
- Enemy: `assets/generated/candidates/bulk-generation-first/enemy_animation_set_candidate_08_chroma_key.png`

Both sources used the transparency fallback before sprite normalization:

- `assets/cleanup/chroma_keyed_adaptive_candidate_07/hero_animation_set_candidate_07_adaptive_alpha.png`
- `assets/cleanup/chroma_keyed_adaptive_candidate_08/enemy_animation_set_candidate_08_adaptive_alpha.png`

Extraction evidence:

- `assets/qa/transparency_tests/adaptive_border_extract_report.candidate_07.animations.json`
- `assets/qa/transparency_tests/adaptive_border_extract_report.candidate_08.enemy.json`

## Pipeline

- Hero used deterministic `4x2` fixed-slot slicing into eight `384x512` raw frames, then shared-scale `512x512` normalization.
- Enemy used component-based slicing from the extracted alpha sheet, sorted row-major, then shared-scale `512x512` normalization. This avoided the cropped/split-frame artifacts caused by the generator placing poses off exact slot centers.

## Outputs

- Hero preview: `assets/sprite_pipeline/candidate_07/hero_animation_set/preview_strip_8col.png`
- Hero contact sheet: `assets/sprite_pipeline/candidate_07/hero_animation_set/contact_sheet_4x2.png`
- Enemy preview: `assets/sprite_pipeline/candidate_08_component/enemy_animation_set/preview_strip_8col.png`
- Enemy contact sheet: `assets/sprite_pipeline/candidate_08_component/enemy_animation_set/contact_sheet_4x2.png`

## Validation

- Extraction warnings: none.
- Extracted alpha range: `0..255`.
- Normalized frame count: `8` for each asset.
- Normalized frame size: `512x512`.
- Normalized frame alpha range: `0..255` for all frames.

## Soft-Alpha Follow-Up

After browser review showed that the animation preview strips were misleading and still had visible chroma matte color on dark backgrounds, the candidate_07 hero and candidate_08 enemy sources were re-extracted with soft key alpha and a one-pixel mask erosion. The latest review previews are transparent PNG strips, not checkerboard-composited RGB previews:

- Hero latest preview: `assets/sprite_pipeline/candidate_07_soft_eroded_component/hero_animation_set/preview_strip_8col.png`
- Enemy latest preview: `assets/sprite_pipeline/candidate_08_soft_eroded_component/enemy_animation_set/preview_strip_8col.png`

## Review Status

These outputs are pending human visual review. They are not approved or integrated.
