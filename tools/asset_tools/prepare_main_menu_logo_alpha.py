#!/usr/bin/env python3
from __future__ import annotations

from collections import deque
from pathlib import Path
import json
import math
import statistics

from PIL import Image


ROOT = Path(__file__).resolve().parents[2]
SOURCE_PATH = ROOT / "assets" / "generated" / "candidates" / "bulk-generation-first" / "game_title_logo_candidate_01.png"
OUTPUT_DIR = ROOT / "resources" / "art" / "assetgen" / "main_menu"
OUTPUT_PATH = OUTPUT_DIR / "game_title_logo_candidate_01_alpha.png"
REPORT_PATH = OUTPUT_DIR / "game_title_logo_candidate_01_alpha_report.json"


def _percentile(values: list[float], pct: float) -> float:
    if not values:
        return 0.0
    if pct <= 0.0:
        return min(values)
    if pct >= 100.0:
        return max(values)
    ordered = sorted(values)
    rank = (len(ordered) - 1) * (pct / 100.0)
    lower = int(math.floor(rank))
    upper = int(math.ceil(rank))
    if lower == upper:
        return float(ordered[lower])
    ratio = rank - lower
    return float(ordered[lower] * (1.0 - ratio) + ordered[upper] * ratio)


def _remove_dark_edge_background(image: Image.Image) -> tuple[Image.Image, dict]:
    rgba = image.convert("RGBA")
    w, h = rgba.size
    border_px = max(8, int(round(min(w, h) * 0.015)))
    px = rgba.load()
    border_samples: list[tuple[int, int, int]] = []
    for x in range(w):
        for y in range(border_px):
            border_samples.append(px[x, y][:3])
            border_samples.append(px[x, h - 1 - y][:3])
    for y in range(h):
        for x in range(border_px):
            border_samples.append(px[x, y][:3])
            border_samples.append(px[w - 1 - x, y][:3])

    bg_rgb = (
        float(statistics.median(sample[0] for sample in border_samples)),
        float(statistics.median(sample[1] for sample in border_samples)),
        float(statistics.median(sample[2] for sample in border_samples)),
    )
    border_dist = [
        math.sqrt((r - bg_rgb[0]) ** 2 + (g - bg_rgb[1]) ** 2 + (b - bg_rgb[2]) ** 2)
        for (r, g, b) in border_samples
    ]
    threshold = float(max(12.0, min(44.0, _percentile(border_dist, 92.0) + 4.0)))

    visited = bytearray(w * h)
    queue: deque[tuple[int, int]] = deque()
    removed = 0

    def _near_background(x: int, y: int) -> bool:
        r, g, b, a = px[x, y]
        if a == 0:
            return False
        if max(r, g, b) > 90:
            return False
        dist = math.sqrt((r - bg_rgb[0]) ** 2 + (g - bg_rgb[1]) ** 2 + (b - bg_rgb[2]) ** 2)
        return dist <= threshold

    def _enqueue(x: int, y: int) -> None:
        if x < 0 or y < 0 or x >= w or y >= h:
            return
        idx = y * w + x
        if visited[idx]:
            return
        visited[idx] = 1
        if _near_background(x, y):
            queue.append((x, y))

    for x in range(w):
        _enqueue(x, 0)
        _enqueue(x, h - 1)
    for y in range(h):
        _enqueue(0, y)
        _enqueue(w - 1, y)

    while queue:
        x, y = queue.popleft()
        r, g, b, a = px[x, y]
        if a > 0:
            px[x, y] = (r, g, b, 0)
            removed += 1
        _enqueue(x + 1, y)
        _enqueue(x - 1, y)
        _enqueue(x, y + 1)
        _enqueue(x, y - 1)

    report = {
        "source_size": [w, h],
        "border_px": border_px,
        "background_rgb_median": [float(bg_rgb[0]), float(bg_rgb[1]), float(bg_rgb[2])],
        "background_distance_threshold": round(threshold, 4),
        "removed_edge_connected_pixels": removed,
    }
    return rgba, report


def main() -> None:
    if not SOURCE_PATH.exists():
        raise SystemExit(f"Missing source image: {SOURCE_PATH}")

    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    source = Image.open(SOURCE_PATH).convert("RGBA")
    source_alpha = source.getchannel("A").getextrema()

    cleaned, cleanup_report = _remove_dark_edge_background(source)
    cleaned.save(OUTPUT_PATH, "PNG")

    alpha_extrema = cleaned.getchannel("A").getextrema()
    alpha_bbox = cleaned.getchannel("A").getbbox()
    payload = {
        "source": str(SOURCE_PATH.relative_to(ROOT)).replace("\\", "/"),
        "output": str(OUTPUT_PATH.relative_to(ROOT)).replace("\\", "/"),
        "source_alpha_minmax": [source_alpha[0], source_alpha[1]],
        "output_alpha_minmax": [alpha_extrema[0], alpha_extrema[1]],
        "output_alpha_bbox": list(alpha_bbox) if alpha_bbox else None,
        "cleanup": cleanup_report,
    }
    REPORT_PATH.write_text(json.dumps(payload, indent=2) + "\n", encoding="utf-8")
    print(json.dumps(payload, indent=2))


if __name__ == "__main__":
    main()
