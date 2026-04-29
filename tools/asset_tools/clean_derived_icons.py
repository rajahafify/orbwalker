#!/usr/bin/env python3
from __future__ import annotations

from collections import deque
from pathlib import Path

from PIL import Image


ROOT = Path(__file__).resolve().parents[2]
ICON_DIR = ROOT / "resources" / "art" / "first_pass" / "derived" / "icons"


def is_checker_like(r: int, g: int, b: int) -> bool:
    max_c = max(r, g, b)
    min_c = min(r, g, b)
    if max_c - min_c > 14:
        return False
    return min_c >= 180


def cut_checkerboard_to_alpha(img: Image.Image) -> Image.Image:
    rgba = img.convert("RGBA")
    w, h = rgba.size
    px = rgba.load()
    visited = bytearray(w * h)
    q: deque[tuple[int, int]] = deque()

    def enqueue(x: int, y: int) -> None:
        if x < 0 or y < 0 or x >= w or y >= h:
            return
        idx = y * w + x
        if visited[idx]:
            return
        visited[idx] = 1
        r, g, b, a = px[x, y]
        if a > 0 and is_checker_like(r, g, b):
            q.append((x, y))

    for x in range(w):
        enqueue(x, 0)
        enqueue(x, h - 1)
    for y in range(h):
        enqueue(0, y)
        enqueue(w - 1, y)

    while q:
        x, y = q.pop()
        r, g, b, _ = px[x, y]
        px[x, y] = (r, g, b, 0)
        enqueue(x + 1, y)
        enqueue(x - 1, y)
        enqueue(x, y + 1)
        enqueue(x, y - 1)
    return rgba


def trim_and_center(img: Image.Image, canvas: int = 384, padding: int = 8) -> Image.Image:
    alpha = img.split()[3]
    box = alpha.getbbox()
    if box is None:
        return img
    cropped = img.crop(box)
    src_w, src_h = cropped.size
    max_side = max(src_w, src_h)
    fit = max(8, canvas - (padding * 2))
    if max_side > fit:
        scale = fit / float(max_side)
        new_w = max(1, int(round(src_w * scale)))
        new_h = max(1, int(round(src_h * scale)))
        cropped = cropped.resize((new_w, new_h), Image.Resampling.LANCZOS)
        src_w, src_h = cropped.size
    out = Image.new("RGBA", (canvas, canvas), (0, 0, 0, 0))
    ox = (canvas - src_w) // 2
    oy = (canvas - src_h) // 2
    out.alpha_composite(cropped, (ox, oy))
    return out


def process_icon(path: Path) -> bool:
    with Image.open(path) as src:
        cleaned = cut_checkerboard_to_alpha(src)
        result = trim_and_center(cleaned)
    changed = True
    result.save(path, "PNG")
    return changed


def main() -> None:
    if not ICON_DIR.exists():
        raise SystemExit(f"Missing icon folder: {ICON_DIR}")
    processed = 0
    for path in sorted(ICON_DIR.glob("*.png")):
        process_icon(path)
        processed += 1
    print(f"Processed icons: {processed}")


if __name__ == "__main__":
    main()
