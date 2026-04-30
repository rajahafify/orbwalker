#!/usr/bin/env python3
from __future__ import annotations

from collections import deque
from pathlib import Path

from PIL import Image


ROOT = Path(__file__).resolve().parents[2]
MENU_DIR = ROOT / "resources" / "art" / "first_pass" / "menu"

GLOBAL_CLEAN_FILES = [
    "main_menu_border_outer_v1.png",
    "main_menu_button_primary_v1.png",
    "main_menu_button_secondary_v1.png",
    "main_menu_stats_triptych_panel_v1.png",
]

EDGE_CLEAN_GLOBS = [
    "main_menu_icon_*.png",
]


def is_checker_like(r: int, g: int, b: int) -> bool:
    max_c = max(r, g, b)
    min_c = min(r, g, b)
    if max_c - min_c > 16:
        return False
    return min_c >= 178


def clean_global_checkerboard(img: Image.Image) -> Image.Image:
    rgba = img.convert("RGBA")
    px = rgba.load()
    w, h = rgba.size
    for y in range(h):
        for x in range(w):
            r, g, b, a = px[x, y]
            if a > 0 and is_checker_like(r, g, b):
                px[x, y] = (r, g, b, 0)
    return rgba


def clean_edge_checkerboard(img: Image.Image) -> Image.Image:
    rgba = img.convert("RGBA")
    px = rgba.load()
    w, h = rgba.size
    visited = bytearray(w * h)
    queue: deque[tuple[int, int]] = deque()

    def enqueue(x: int, y: int) -> None:
        if x < 0 or y < 0 or x >= w or y >= h:
            return
        idx = y * w + x
        if visited[idx]:
            return
        visited[idx] = 1
        r, g, b, a = px[x, y]
        if a > 0 and is_checker_like(r, g, b):
            queue.append((x, y))

    for x in range(w):
        enqueue(x, 0)
        enqueue(x, h - 1)
    for y in range(h):
        enqueue(0, y)
        enqueue(w - 1, y)

    while queue:
        x, y = queue.pop()
        r, g, b, _ = px[x, y]
        px[x, y] = (r, g, b, 0)
        enqueue(x + 1, y)
        enqueue(x - 1, y)
        enqueue(x, y + 1)
        enqueue(x, y - 1)

    return rgba


def alpha_summary(path: Path) -> str:
    with Image.open(path) as img:
        rgba = img.convert("RGBA")
        alpha = rgba.getchannel("A")
        extrema = alpha.getextrema()
        return f"{path.name}: alpha={extrema[0]}-{extrema[1]}"


def save_cleaned(path: Path, edge_only: bool) -> None:
    with Image.open(path) as source:
        cleaned = clean_edge_checkerboard(source) if edge_only else clean_global_checkerboard(source)
    cleaned.save(path, "PNG")


def main() -> None:
    if not MENU_DIR.exists():
        raise SystemExit(f"Missing menu folder: {MENU_DIR}")

    processed: list[Path] = []
    for name in GLOBAL_CLEAN_FILES:
        path = MENU_DIR / name
        if not path.exists():
            raise SystemExit(f"Missing menu asset: {path}")
        save_cleaned(path, edge_only=False)
        processed.append(path)

    for pattern in EDGE_CLEAN_GLOBS:
        for path in sorted(MENU_DIR.glob(pattern)):
            save_cleaned(path, edge_only=True)
            processed.append(path)

    for path in processed:
        print(alpha_summary(path))


if __name__ == "__main__":
    main()
