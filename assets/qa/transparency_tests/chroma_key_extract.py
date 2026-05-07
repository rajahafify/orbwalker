#!/usr/bin/env python3
"""Extract alpha from intentionally generated chroma-key asset sheets."""

from __future__ import annotations

import argparse
import json
from collections import deque
from pathlib import Path
from typing import Iterable

from PIL import Image


KEYS = {
    "cyan": (0, 255, 255),
    "magenta": (255, 0, 255),
}


def parse_key(value: str) -> tuple[int, int, int]:
    lowered = value.lower()
    if lowered in KEYS:
        return KEYS[lowered]
    if lowered.startswith("#") and len(lowered) == 7:
        return tuple(int(lowered[i : i + 2], 16) for i in (1, 3, 5))  # type: ignore[return-value]
    raise argparse.ArgumentTypeError("key must be cyan, magenta, or #RRGGBB")


def color_distance_sq(pixel: tuple[int, int, int], key: tuple[int, int, int]) -> int:
    return sum((int(pixel[i]) - key[i]) ** 2 for i in range(3))


def iter_edge_pixels(width: int, height: int) -> Iterable[tuple[int, int]]:
    for x in range(width):
        yield x, 0
        yield x, height - 1
    for y in range(1, height - 1):
        yield 0, y
        yield width - 1, y


def extract_one(
    source: Path,
    output: Path,
    key: tuple[int, int, int],
    exact_tolerance: int,
    feather_tolerance: int,
) -> dict:
    image = Image.open(source).convert("RGBA")
    pixels = image.load()
    width, height = image.size
    exact_sq = exact_tolerance * exact_tolerance
    feather_sq = feather_tolerance * feather_tolerance
    visited = bytearray(width * height)
    background = bytearray(width * height)
    key_pixels = 0
    feather_pixels = 0
    opaque_pixels = 0
    non_key_edge_pixels = 0

    def index(x: int, y: int) -> int:
        return y * width + x

    queue: deque[tuple[int, int]] = deque()
    for x, y in iter_edge_pixels(width, height):
        rgb = pixels[x, y][:3]
        if color_distance_sq(rgb, key) > exact_sq:
            non_key_edge_pixels += 1
        if color_distance_sq(rgb, key) <= feather_sq:
            idx = index(x, y)
            if not visited[idx]:
                visited[idx] = 1
                queue.append((x, y))

    while queue:
        x, y = queue.popleft()
        background[index(x, y)] = 1
        for nx, ny in ((x - 1, y), (x + 1, y), (x, y - 1), (x, y + 1)):
            if nx < 0 or ny < 0 or nx >= width or ny >= height:
                continue
            idx = index(nx, ny)
            if visited[idx]:
                continue
            rgb = pixels[nx, ny][:3]
            if color_distance_sq(rgb, key) <= feather_sq:
                visited[idx] = 1
                queue.append((nx, ny))

    for y in range(height):
        for x in range(width):
            r, g, b, _a = pixels[x, y]
            idx = index(x, y)
            if not background[idx]:
                pixels[x, y] = (r, g, b, 255)
                opaque_pixels += 1
                continue
            dist_sq = color_distance_sq((r, g, b), key)
            if dist_sq <= exact_sq:
                pixels[x, y] = (r, g, b, 0)
                key_pixels += 1
            else:
                alpha_value = int(255 * (dist_sq - exact_sq) / max(1, feather_sq - exact_sq))
                pixels[x, y] = (r, g, b, max(0, min(255, alpha_value)))
                feather_pixels += 1

    alpha = image.getchannel("A")
    bbox = alpha.getbbox()

    output.parent.mkdir(parents=True, exist_ok=True)
    image.save(output)
    hist = alpha.histogram()
    warnings = []
    if key_pixels == 0:
        warnings.append("no_key_pixels_removed")
    if hist[0] == 0:
        warnings.append("no_zero_alpha_after_extract")
    if hist[255] == width * height:
        warnings.append("all_pixels_opaque_after_extract")
    edge_total = width * 2 + max(0, height - 2) * 2
    if edge_total and non_key_edge_pixels / edge_total > 0.05:
        warnings.append("source_edges_not_flat_key")
    if bbox is None:
        warnings.append("no_opaque_asset_bbox_after_extract")

    return {
        "source": str(source).replace("\\", "/"),
        "output": str(output).replace("\\", "/"),
        "size": [width, height],
        "key_rgb": key,
        "exact_tolerance": exact_tolerance,
        "feather_tolerance": feather_tolerance,
        "key_pixels": key_pixels,
        "feather_pixels": feather_pixels,
        "opaque_pixels": opaque_pixels,
        "alpha_zero": hist[0],
        "alpha_partial": sum(hist[1:255]),
        "alpha_opaque": hist[255],
        "alpha_minmax": alpha.getextrema(),
        "non_key_edge_pixels": non_key_edge_pixels,
        "connected_background_pixels": key_pixels + feather_pixels,
        "warnings": warnings,
    }


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--input", action="append", required=True)
    parser.add_argument("--output-dir", required=True)
    parser.add_argument("--key", action="append", required=True, type=parse_key)
    parser.add_argument("--report", required=True)
    parser.add_argument("--exact-tolerance", type=int, default=6)
    parser.add_argument("--feather-tolerance", type=int, default=42)
    args = parser.parse_args()

    if len(args.input) != len(args.key):
        parser.error("--input and --key counts must match")

    output_dir = Path(args.output_dir)
    results = []
    for input_path, key in zip(args.input, args.key):
        source = Path(input_path)
        output = output_dir / source.name.replace("_chroma_key.png", "_chroma_alpha.png")
        results.append(extract_one(source, output, key, args.exact_tolerance, args.feather_tolerance))

    Path(args.report).parent.mkdir(parents=True, exist_ok=True)
    Path(args.report).write_text(json.dumps({"results": results}, indent=2) + "\n", encoding="utf-8")
    print(json.dumps({"processed": len(results), "report": args.report}, indent=2))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
