# Alpha Cleanup Probe

Deterministic QA cleanup helper for generated PNGs that have mostly uniform edge background but no real alpha.

## What it does

- Estimates background color from border pixels.
- Computes color distance per pixel.
- Removes only edge-connected near-background regions.
- Adds feathered alpha at the foreground edge.
- Writes cleaned PNGs to `assets/cleanup/alpha_fixed/`.
- Emits a JSON report with dimensions, pixel format, sample counts, and warnings.

## Usage

```powershell
python assets/qa/transparency_tests/alpha_cleanup_probe.py \
  assets/generated/candidates/bulk-generation-first/board_orb_clear_vfx_candidate_01.png \
  assets/generated/candidates/bulk-generation-first/intent_icons_candidate_01.png \
  assets/generated/candidates/bulk-generation-first/shop_ui_pack_candidate_01.png \
  --output-dir assets/cleanup/alpha_fixed \
  --report assets/qa/transparency_tests/alpha_cleanup_probe_report.json
```

Optional tuning flags:

- `--border-width` (default `6`)
- `--border-percentile` (default `97`)
- `--base-margin` (default `2`)
- `--feather-width` (default `24`)
- `--samples-per-axis` (default `97`)

This helper is intentionally deterministic and does not update manifests.