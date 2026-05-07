# Sprite Pipeline Candidate 06 Normalization

Date: 2026-05-08  
Scope: `hero_animation_set`, `enemy_animation_set`  
Mode: chroma-key fallback source generation -> adaptive real-alpha extraction -> deterministic 4x2 slicing -> 8-frame normalization

## Inputs

- `assets/generated/candidates/bulk-generation-first/hero_animation_set_candidate_06_chroma_key.png`
- `assets/generated/candidates/bulk-generation-first/enemy_animation_set_candidate_06_chroma_key.png`

Both animation sources were generated as opaque chroma-key sheets, then extracted to real-alpha RGBA before sprite slicing:

- `assets/cleanup/chroma_keyed_adaptive_candidate_06/hero_animation_set_candidate_06_adaptive_alpha.png`
- `assets/cleanup/chroma_keyed_adaptive_candidate_06/enemy_animation_set_candidate_06_adaptive_alpha.png`

Extraction evidence:

- `assets/qa/transparency_tests/adaptive_border_extract_report.candidate_06.remaining.json`

## Pipeline Steps

1. Slice each extracted RGBA `1536x1024` sheet into a `4x2` grid of eight `384x512` raw frames.
2. Assemble `source_rowmajor_strip.png`.
3. Normalize every frame to `512x512` using one shared scale per asset and bottom-center alignment.
4. Render review previews:
   - `preview_strip_8col.png`
   - `contact_sheet_4x2.png`

## Outputs

### Hero

- Base: `assets/sprite_pipeline/candidate_06/hero_animation_set/`
- Raw frames: `assets/sprite_pipeline/candidate_06/hero_animation_set/raw_frames/01.png` .. `08.png`
- Normalized frames: `assets/sprite_pipeline/candidate_06/hero_animation_set/normalized_frames/01.png` .. `08.png`
- Preview strip: `assets/sprite_pipeline/candidate_06/hero_animation_set/preview_strip_8col.png`
- Contact sheet: `assets/sprite_pipeline/candidate_06/hero_animation_set/contact_sheet_4x2.png`

### Enemy

- Base: `assets/sprite_pipeline/candidate_06/enemy_animation_set/`
- Raw frames: `assets/sprite_pipeline/candidate_06/enemy_animation_set/raw_frames/01.png` .. `08.png`
- Normalized frames: `assets/sprite_pipeline/candidate_06/enemy_animation_set/normalized_frames/01.png` .. `08.png`
- Preview strip: `assets/sprite_pipeline/candidate_06/enemy_animation_set/preview_strip_8col.png`
- Contact sheet: `assets/sprite_pipeline/candidate_06/enemy_animation_set/contact_sheet_4x2.png`

## Validation

- Adaptive extraction warnings: none for both animation sheets.
- Extracted alpha range: `0..255` for both animation sheets.
- Normalized frame count: `8` for each asset.
- Normalized frame size: `512x512` each frame.
- Normalized frame alpha range: `0..255` for all frames.

## Review Status

Candidate_06 outputs are ready for human visual review. They are not approved or integrated.
