#!/usr/bin/env python3
"""Remove connected generated backgrounds by sampling border colors."""

from __future__ import annotations

import argparse
import json
from collections import deque
from pathlib import Path

from PIL import Image


def dist_sq(a: tuple[int, int, int], b: tuple[int, int, int]) -> int:
    return sum((int(a[i]) - int(b[i])) ** 2 for i in range(3))


def border_points(width: int, height: int, stride: int) -> list[tuple[int, int]]:
    pts: list[tuple[int, int]] = []
    for x in range(0, width, stride):
        pts.append((x, 0))
        pts.append((x, height - 1))
    for y in range(0, height, stride):
        pts.append((0, y))
        pts.append((width - 1, y))
    return pts


def extract(source: Path, output: Path, tolerance: int, stride: int) -> dict:
    image = Image.open(source).convert("RGBA")
    px = image.load()
    width, height = image.size
    tol_sq = tolerance * tolerance
    samples = [px[x, y][:3] for x, y in border_points(width, height, stride)]
    visited = bytearray(width * height)
    bg = bytearray(width * height)
    q: deque[tuple[int, int]] = deque()

    def idx(x: int, y: int) -> int:
        return y * width + x

    def is_background(rgb: tuple[int, int, int]) -> bool:
        return any(dist_sq(rgb, sample) <= tol_sq for sample in samples)

    for x, y in border_points(width, height, 1):
        i = idx(x, y)
        if not visited[i] and is_background(px[x, y][:3]):
            visited[i] = 1
            q.append((x, y))

    while q:
        x, y = q.popleft()
        bg[idx(x, y)] = 1
        for nx, ny in ((x - 1, y), (x + 1, y), (x, y - 1), (x, y + 1)):
            if nx < 0 or ny < 0 or nx >= width or ny >= height:
                continue
            i = idx(nx, ny)
            if visited[i]:
                continue
            visited[i] = 1
            if is_background(px[nx, ny][:3]):
                q.append((nx, ny))

    removed = 0
    kept = 0
    for y in range(height):
        for x in range(width):
            r, g, b, _a = px[x, y]
            if bg[idx(x, y)]:
                px[x, y] = (r, g, b, 0)
                removed += 1
            else:
                px[x, y] = (r, g, b, 255)
                kept += 1

    output.parent.mkdir(parents=True, exist_ok=True)
    image.save(output)
    alpha = image.getchannel("A")
    hist = alpha.histogram()
    warnings = []
    if hist[0] == 0:
        warnings.append("no_zero_alpha_after_extract")
    if hist[255] == width * height:
        warnings.append("all_pixels_opaque_after_extract")
    if removed / (width * height) < 0.1:
        warnings.append("low_background_removed_fraction")
    if kept / (width * height) < 0.05:
        warnings.append("low_asset_kept_fraction")
    return {
        "source": str(source).replace("\\", "/"),
        "output": str(output).replace("\\", "/"),
        "size": [width, height],
        "tolerance": tolerance,
        "sample_stride": stride,
        "removed_connected_background": removed,
        "kept_pixels": kept,
        "alpha_zero": hist[0],
        "alpha_partial": sum(hist[1:255]),
        "alpha_opaque": hist[255],
        "alpha_minmax": alpha.getextrema(),
        "warnings": warnings,
    }


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--input", action="append", required=True)
    parser.add_argument("--output-dir", required=True)
    parser.add_argument("--report", required=True)
    parser.add_argument("--tolerance", type=int, default=58)
    parser.add_argument("--sample-stride", type=int, default=24)
    args = parser.parse_args()

    results = []
    for input_path in args.input:
        src = Path(input_path)
        out = Path(args.output_dir) / src.name.replace("_chroma_key.png", "_adaptive_alpha.png")
        results.append(extract(src, out, args.tolerance, args.sample_stride))

    Path(args.report).parent.mkdir(parents=True, exist_ok=True)
    Path(args.report).write_text(json.dumps({"results": results}, indent=2) + "\n", encoding="utf-8")
    print(json.dumps({"processed": len(results), "report": args.report}, indent=2))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
