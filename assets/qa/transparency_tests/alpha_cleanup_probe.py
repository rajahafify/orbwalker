from pathlib import Path
import json
import argparse
from collections import deque

import numpy as np
from PIL import Image


def _border_pixels(rgb: np.ndarray, border_width: int) -> np.ndarray:
    h, w, _ = rgb.shape
    bw = max(1, min(border_width, h // 2, w // 2))
    top = rgb[:bw, :, :].reshape(-1, 3)
    bottom = rgb[h - bw :, :, :].reshape(-1, 3)
    left = rgb[bw : h - bw, :bw, :].reshape(-1, 3)
    right = rgb[bw : h - bw, w - bw :, :].reshape(-1, 3)
    return np.concatenate([top, bottom, left, right], axis=0)


def _edge_connected_mask(candidate_mask: np.ndarray) -> np.ndarray:
    h, w = candidate_mask.shape
    visited = np.zeros((h, w), dtype=bool)
    queue = deque()

    def enqueue_if_needed(y: int, x: int) -> None:
        if candidate_mask[y, x] and not visited[y, x]:
            visited[y, x] = True
            queue.append((y, x))

    for x in range(w):
        enqueue_if_needed(0, x)
        enqueue_if_needed(h - 1, x)
    for y in range(h):
        enqueue_if_needed(y, 0)
        enqueue_if_needed(y, w - 1)

    while queue:
        y, x = queue.popleft()
        if y > 0:
            enqueue_if_needed(y - 1, x)
        if y < h - 1:
            enqueue_if_needed(y + 1, x)
        if x > 0:
            enqueue_if_needed(y, x - 1)
        if x < w - 1:
            enqueue_if_needed(y, x + 1)

    return visited


def _alpha_sample_counts(alpha: np.ndarray, samples_per_axis: int) -> dict:
    h, w = alpha.shape
    y_count = max(1, min(samples_per_axis, h))
    x_count = max(1, min(samples_per_axis, w))
    ys = np.linspace(0, h - 1, num=y_count, dtype=int)
    xs = np.linspace(0, w - 1, num=x_count, dtype=int)
    sampled = alpha[np.ix_(ys, xs)]
    transparent = int(np.count_nonzero(sampled == 0))
    partial = int(np.count_nonzero((sampled > 0) & (sampled < 255)))
    opaque = int(np.count_nonzero(sampled == 255))
    return {
        "sampled": int(sampled.size),
        "transparent_samples": transparent,
        "partial_alpha_samples": partial,
        "opaque_samples": opaque,
    }


def _process_image(input_path: Path, output_path: Path, border_width: int, border_percentile: float, base_margin: float, feather_width: float, samples_per_axis: int) -> dict:
    image = Image.open(input_path).convert("RGB")
    rgb = np.array(image, dtype=np.uint8)
    h, w, _ = rgb.shape

    border = _border_pixels(rgb, border_width)
    bg_color = np.median(border, axis=0)

    rgb_float = rgb.astype(np.float32)
    dist = np.linalg.norm(rgb_float - bg_color.reshape(1, 1, 3), axis=2)

    border_dist = np.linalg.norm(border.astype(np.float32) - bg_color.reshape(1, 3), axis=1)
    t0 = float(np.percentile(border_dist, border_percentile) + base_margin)
    t0 = max(t0, 1.0)
    t1 = t0 + max(feather_width, 1.0)

    near_background = dist <= t1
    removable = _edge_connected_mask(near_background)

    alpha = np.full((h, w), 255, dtype=np.uint8)
    full_clear = removable & (dist <= t0)
    feather = removable & (dist > t0) & (dist < t1)

    alpha[full_clear] = 0
    if np.any(feather):
        alpha_values = ((dist[feather] - t0) / (t1 - t0) * 255.0)
        alpha[feather] = np.clip(alpha_values, 0, 255).astype(np.uint8)

    rgba = np.dstack([rgb, alpha])
    rgba[alpha == 0, :3] = 0

    output_path.parent.mkdir(parents=True, exist_ok=True)
    Image.fromarray(rgba, mode="RGBA").save(output_path, format="PNG")

    warnings = []
    border_std = border.astype(np.float32).std(axis=0)
    if float(border_std.max()) > 12.0:
        warnings.append("border_variance_high_background_may_be_nonuniform")
    removable_ratio = float(np.count_nonzero(removable)) / float(h * w)
    if removable_ratio < 0.02:
        warnings.append("low_background_removal_ratio_check_thresholds")
    opaque_ratio = float(np.count_nonzero(alpha == 255)) / float(h * w)
    if opaque_ratio < 0.02:
        warnings.append("very_low_opaque_ratio_possible_over_removal")

    sample_counts = _alpha_sample_counts(alpha, samples_per_axis)

    return {
        "input_path": str(input_path).replace("\\", "/"),
        "output_path": str(output_path).replace("\\", "/"),
        "dimensions": f"{w}x{h}",
        "pixel_format": "RGBA (equivalent real alpha)",
        "background_color_rgb": [int(round(c)) for c in bg_color.tolist()],
        "thresholds": {
            "full_clear_distance": round(t0, 4),
            "feather_end_distance": round(t1, 4),
            "border_percentile": border_percentile,
            "base_margin": base_margin,
            "feather_width": feather_width,
        },
        "full_pixel_counts": {
            "transparent_pixels": int(np.count_nonzero(alpha == 0)),
            "partial_alpha_pixels": int(np.count_nonzero((alpha > 0) & (alpha < 255))),
            "opaque_pixels": int(np.count_nonzero(alpha == 255)),
            "total_pixels": int(h * w),
        },
        "sample_counts": sample_counts,
        "warnings": warnings,
    }


def main() -> None:
    parser = argparse.ArgumentParser(description="Deterministic edge-connected transparency cleanup for generated PNG sheets.")
    parser.add_argument("inputs", nargs="+", help="Input PNG paths.")
    parser.add_argument("--output-dir", default="assets/cleanup/alpha_fixed", help="Directory for cleaned PNG output.")
    parser.add_argument("--report", default="assets/qa/transparency_tests/alpha_cleanup_probe_report.json", help="JSON report output path.")
    parser.add_argument("--border-width", type=int, default=6)
    parser.add_argument("--border-percentile", type=float, default=97.0)
    parser.add_argument("--base-margin", type=float, default=2.0)
    parser.add_argument("--feather-width", type=float, default=24.0)
    parser.add_argument("--samples-per-axis", type=int, default=97)
    args = parser.parse_args()

    output_dir = Path(args.output_dir)
    entries = []
    for raw in args.inputs:
        input_path = Path(raw)
        if not input_path.exists():
            entries.append({
                "input_path": str(input_path).replace("\\", "/"),
                "exists": False,
                "warnings": ["input_missing"],
            })
            continue

        output_name = input_path.stem + "_alpha_fixed.png"
        output_path = output_dir / output_name
        entry = _process_image(
            input_path=input_path,
            output_path=output_path,
            border_width=args.border_width,
            border_percentile=args.border_percentile,
            base_margin=args.base_margin,
            feather_width=args.feather_width,
            samples_per_axis=args.samples_per_axis,
        )
        entry["exists"] = True
        entries.append(entry)

    report = {
        "tool": "alpha_cleanup_probe",
        "mode": "deterministic_edge_connected_background_removal",
        "output_dir": str(output_dir).replace("\\", "/"),
        "parameters": {
            "border_width": args.border_width,
            "border_percentile": args.border_percentile,
            "base_margin": args.base_margin,
            "feather_width": args.feather_width,
            "samples_per_axis": args.samples_per_axis,
        },
        "entries": entries,
    }

    report_path = Path(args.report)
    report_path.parent.mkdir(parents=True, exist_ok=True)
    report_path.write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")


if __name__ == "__main__":
    main()