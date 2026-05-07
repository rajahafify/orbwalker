# Sprite Pipeline Candidate 04 Normalization

Date: 2026-05-08  
Scope: `hero_animation_set`, `enemy_animation_set`  
Mode: deterministic 4x2 slicing -> 8-frame normalization (no image generation)

## Inputs

- `assets/cleanup/chroma_keyed_adaptive_all/hero_animation_set_candidate_04_adaptive_alpha.png`
- `assets/cleanup/chroma_keyed_adaptive_all/enemy_animation_set_candidate_04_adaptive_alpha.png`

Both sources are `1536x1024` RGBA with real alpha. Deterministic slicing used:

- Grid: `4` columns x `2` rows
- Cell/frame slot: `384x512`
- Frame order: row-major (`top-left -> top-right`, then second row left-to-right)

## Pipeline Steps

1. Slice each 4x2 sheet into 8 raw frames (`raw_frames/01..08.png`).
2. Assemble a deterministic horizontal strip (`source_rowmajor_strip.png`, `3072x512`).
3. Run `game-studio:sprite-pipeline` normalization script:
   - `normalize_sprite_strip.py --frames 8 --frame-size 512`
   - shared scale + bottom-center alignment across all frames
4. Render preview artifacts with `render_sprite_preview_sheet.py`:
   - `preview_strip_8col.png` (8 columns)
   - `contact_sheet_4x2.png` (4 columns x 2 rows)

## Outputs

### Hero

- Base: `assets/sprite_pipeline/candidate_04/hero_animation_set/`
- Raw frames: `assets/sprite_pipeline/candidate_04/hero_animation_set/raw_frames/01.png` .. `08.png`
- Normalized frames: `assets/sprite_pipeline/candidate_04/hero_animation_set/normalized_frames/01.png` .. `08.png`
- Preview strip: `assets/sprite_pipeline/candidate_04/hero_animation_set/preview_strip_8col.png`
- Contact sheet: `assets/sprite_pipeline/candidate_04/hero_animation_set/contact_sheet_4x2.png`

### Enemy

- Base: `assets/sprite_pipeline/candidate_04/enemy_animation_set/`
- Raw frames: `assets/sprite_pipeline/candidate_04/enemy_animation_set/raw_frames/01.png` .. `08.png`
- Normalized frames: `assets/sprite_pipeline/candidate_04/enemy_animation_set/normalized_frames/01.png` .. `08.png`
- Preview strip: `assets/sprite_pipeline/candidate_04/enemy_animation_set/preview_strip_8col.png`
- Contact sheet: `assets/sprite_pipeline/candidate_04/enemy_animation_set/contact_sheet_4x2.png`

## Validation

Checked both normalized frame sets:

- Frame count: `8` each
- Normalized frame size: `512x512` each frame
- Alpha range across normalized frames: `0..255` (real alpha preserved)
- Non-empty frames: `8/8` for both sets

Preview dimensions:

- `preview_strip_8col.png`: `4152x512`
- `contact_sheet_4x2.png`: `2072x1032`

## Risks / Follow-up

- Frame order is strictly row-major from the source grid; if gameplay expects a different timeline order, reorder is still needed before runtime integration.
- This pass validates file outputs, dimensions, and alpha preservation only; in-engine animation playback timing and anchor fit still need runtime QA.
- Aggregate manifests/status files were intentionally not updated in this pass.
