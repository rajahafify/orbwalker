#!/usr/bin/env python3
from __future__ import annotations

from collections import deque
from dataclasses import dataclass
from pathlib import Path
import json

from PIL import Image, ImageDraw


ROOT = Path(__file__).resolve().parents[2]
SOURCE_IMAGE = ROOT / "assets" / "cleanup" / "chroma_keyed_adaptive_ui_retry" / "main_menu_ui_pack_candidate_05_adaptive_alpha.png"
OUTPUT_DIR = ROOT / "resources" / "art" / "assetgen" / "main_menu"
PREVIEW_PATH = OUTPUT_DIR / "preview" / "main_menu_ui_pack_candidate_05_components_preview.png"
REPORT_PATH = OUTPUT_DIR / "main_menu_ui_pack_candidate_05_extract_report.json"

ICON_OUTPUTS = [
    "main_menu_icon_profile_candidate_05.png",
    "main_menu_icon_settings_candidate_05.png",
    "main_menu_icon_achievements_candidate_05.png",
    "main_menu_icon_relic_chest_candidate_05.png",
    "main_menu_icon_mastery_progress_candidate_05.png",
    "main_menu_icon_best_run_candidate_05.png",
]

SEMANTIC_ICON_SOURCES = {
    "main_menu_icon_profile_candidate_05.png": ROOT / "resources" / "art" / "first_pass" / "menu" / "main_menu_icon_profile_v1.png",
    "main_menu_icon_settings_candidate_05.png": ROOT / "resources" / "art" / "first_pass" / "menu" / "main_menu_icon_settings_v1.png",
    "main_menu_icon_achievements_candidate_05.png": ROOT / "resources" / "art" / "first_pass" / "menu" / "main_menu_icon_achievements_v1.png",
    "main_menu_icon_relic_chest_candidate_05.png": ROOT / "resources" / "art" / "first_pass" / "menu" / "main_menu_icon_relic_chest_v1.png",
    "main_menu_icon_mastery_progress_candidate_05.png": ROOT / "resources" / "art" / "first_pass" / "menu" / "main_menu_icon_mastery_progress_v1.png",
    "main_menu_icon_best_run_candidate_05.png": ROOT / "resources" / "art" / "first_pass" / "menu" / "main_menu_icon_best_run_demon_v1.png",
}
OPTIONAL_STATS_PANEL_FRAME_ONLY_OUTPUT = "main_menu_stats_panel_candidate_05_frame_only.png"


@dataclass(frozen=True)
class Component:
    bbox: tuple[int, int, int, int]
    pixel_count: int
    mean_luma: float


def _component_luma(image: Image.Image, bbox: tuple[int, int, int, int]) -> float:
    rgba = image.crop(bbox).convert("RGBA")
    px = rgba.load()
    w, h = rgba.size
    total = 0.0
    count = 0
    for y in range(h):
        for x in range(w):
            r, g, b, a = px[x, y]
            if a == 0:
                continue
            total += (0.2126 * r) + (0.7152 * g) + (0.0722 * b)
            count += 1
    return (total / count) if count else 0.0


def find_components(image: Image.Image) -> list[Component]:
    alpha = image.getchannel("A")
    alpha_px = alpha.load()
    w, h = image.size
    visited = bytearray(w * h)
    components: list[Component] = []

    for y in range(h):
        for x in range(w):
            idx = y * w + x
            if visited[idx] or alpha_px[x, y] == 0:
                continue

            queue: deque[tuple[int, int]] = deque([(x, y)])
            visited[idx] = 1
            min_x = max_x = x
            min_y = max_y = y
            count = 0

            while queue:
                cx, cy = queue.popleft()
                count += 1
                min_x = min(min_x, cx)
                max_x = max(max_x, cx)
                min_y = min(min_y, cy)
                max_y = max(max_y, cy)
                for nx, ny in ((cx + 1, cy), (cx - 1, cy), (cx, cy + 1), (cx, cy - 1)):
                    if nx < 0 or ny < 0 or nx >= w or ny >= h:
                        continue
                    nidx = ny * w + nx
                    if visited[nidx] or alpha_px[nx, ny] == 0:
                        continue
                    visited[nidx] = 1
                    queue.append((nx, ny))

            bbox = (min_x, min_y, max_x + 1, max_y + 1)
            components.append(Component(bbox=bbox, pixel_count=count, mean_luma=_component_luma(image, bbox)))

    return components


def classify_components(components: list[Component]) -> dict[str, Component]:
    if len(components) != 10:
        raise SystemExit(f"Expected 10 components (4 chrome + 6 icons), found {len(components)}")

    top = sorted([c for c in components if c.bbox[1] < 520], key=lambda c: c.bbox[0])
    middle = sorted([c for c in components if 520 <= c.bbox[1] < 730], key=lambda c: c.bbox[0])
    bottom = sorted([c for c in components if c.bbox[1] >= 730], key=lambda c: c.bbox[0])

    if len(top) != 2 or len(middle) != 2 or len(bottom) != 6:
        raise SystemExit(
            "Unexpected row split for candidate_05 components. "
            f"top={len(top)} middle={len(middle)} bottom={len(bottom)}"
        )

    darker, brighter = sorted(middle, key=lambda c: c.mean_luma)

    mapping: dict[str, Component] = {
        "main_menu_border_outer_candidate_05.png": top[0],
        "main_menu_stats_panel_candidate_05.png": top[1],
        "main_menu_button_secondary_candidate_05.png": darker,
        "main_menu_button_primary_candidate_05.png": brighter,
    }

    for idx, name in enumerate(ICON_OUTPUTS):
        mapping[name] = bottom[idx]

    return mapping


def _is_magenta_spill(r: int, g: int, b: int, a: int) -> bool:
    if a == 0:
        return False
    if r < 120 or b < 108 or g > 112:
        return False
    if abs(r - b) > 96:
        return False
    return (max(r, b) - g) >= 72


def _clear_edge_connected_magenta_spill(image: Image.Image) -> tuple[Image.Image, int]:
    rgba = image.convert("RGBA")
    px = rgba.load()
    w, h = rgba.size
    visited = bytearray(w * h)
    queue: deque[tuple[int, int]] = deque()
    removed = 0

    def enqueue_if_spill(x: int, y: int) -> None:
        if x < 0 or y < 0 or x >= w or y >= h:
            return
        idx = y * w + x
        if visited[idx]:
            return
        visited[idx] = 1
        if _is_magenta_spill(*px[x, y]):
            queue.append((x, y))

    for x in range(w):
        enqueue_if_spill(x, 0)
        enqueue_if_spill(x, h - 1)
    for y in range(h):
        enqueue_if_spill(0, y)
        enqueue_if_spill(w - 1, y)

    while queue:
        x, y = queue.popleft()
        r, g, b, a = px[x, y]
        if a > 0:
            px[x, y] = (r, g, b, 0)
            removed += 1
        for nx, ny in ((x + 1, y), (x - 1, y), (x, y + 1), (x, y - 1)):
            enqueue_if_spill(nx, ny)

    return rgba, removed


def save_crops(image: Image.Image, mapping: dict[str, Component]) -> dict[str, int]:
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    cleaned_pixel_counts: dict[str, int] = {}
    for name, comp in mapping.items():
        crop = image.crop(comp.bbox)
        crop, removed = _clear_edge_connected_magenta_spill(crop)
        crop.save(OUTPUT_DIR / name, "PNG")
        cleaned_pixel_counts[name] = removed
    return cleaned_pixel_counts


def _alpha_bbox(image: Image.Image) -> tuple[int, int, int, int] | None:
    return image.getchannel("A").getbbox()


def _recolor_semantic_glyph(glyph: Image.Image) -> Image.Image:
    colored = glyph.convert("RGBA")
    px = colored.load()
    w, h = colored.size
    for y in range(h):
        for x in range(w):
            r, g, b, a = px[x, y]
            if a == 0:
                continue
            luma = int(round((0.2126 * r) + (0.7152 * g) + (0.0722 * b)))
            tone = float(luma) / 255.0
            px[x, y] = (
                int(round(150 + (92 * tone))),
                int(round(110 + (84 * tone))),
                int(round(52 + (56 * tone))),
                a,
            )
    return colored


def _compose_semantic_icon(frame_path: Path, glyph_path: Path, output_path: Path) -> None:
    frame = Image.open(frame_path).convert("RGBA")
    glyph_source = Image.open(glyph_path).convert("RGBA")
    glyph_bbox = _alpha_bbox(glyph_source)
    if glyph_bbox is None:
        frame.save(output_path, "PNG")
        return
    glyph = glyph_source.crop(glyph_bbox)
    glyph = _recolor_semantic_glyph(glyph)
    frame_bbox = _alpha_bbox(frame)
    if frame_bbox is None:
        frame.save(output_path, "PNG")
        return
    frame_w = frame_bbox[2] - frame_bbox[0]
    frame_h = frame_bbox[3] - frame_bbox[1]
    glyph_target_side = max(1, int(round(min(frame_w, frame_h) * 0.54)))
    scale = min(glyph_target_side / glyph.width, glyph_target_side / glyph.height)
    glyph_size = (
        max(1, int(round(glyph.width * scale))),
        max(1, int(round(glyph.height * scale))),
    )
    glyph = glyph.resize(glyph_size, Image.Resampling.LANCZOS)

    shadow = Image.new("RGBA", glyph_size, (0, 0, 0, 0))
    glyph_alpha = glyph.getchannel("A")
    shadow.putalpha(glyph_alpha.point(lambda alpha: int(round(alpha * 0.42))))
    shadow_layer = Image.new("RGBA", frame.size, (0, 0, 0, 0))

    center_x = int(round((frame_bbox[0] + frame_bbox[2]) * 0.5))
    center_y = int(round((frame_bbox[1] + frame_bbox[3]) * 0.5))
    base_x = center_x - (glyph_size[0] // 2)
    base_y = center_y - (glyph_size[1] // 2) - int(round(frame_h * 0.02))
    shadow_layer.alpha_composite(shadow, (base_x + 2, base_y + 2))

    composed = frame.copy()
    composed.alpha_composite(shadow_layer)
    composed.alpha_composite(glyph, (base_x, base_y))
    composed.save(output_path, "PNG")


def write_semantic_icon_outputs() -> dict[str, str]:
    outputs: dict[str, str] = {}
    for frame_name, glyph_path in SEMANTIC_ICON_SOURCES.items():
        frame_path = OUTPUT_DIR / frame_name
        semantic_name = frame_name.replace(".png", "_semantic.png")
        semantic_path = OUTPUT_DIR / semantic_name
        if not frame_path.exists():
            raise SystemExit(f"Missing extracted frame for semantic icon compose: {frame_path}")
        if not glyph_path.exists():
            raise SystemExit(f"Missing semantic icon source: {glyph_path}")
        _compose_semantic_icon(frame_path, glyph_path, semantic_path)
        outputs[frame_name] = semantic_name
    return outputs


def write_optional_stats_panel_frame_only() -> str:
    source_path = OUTPUT_DIR / "main_menu_stats_panel_candidate_05.png"
    if not source_path.exists():
        raise SystemExit(f"Missing stats panel for frame-only output: {source_path}")
    panel = Image.open(source_path).convert("RGBA")
    px = panel.load()
    w, h = panel.size
    inset = max(20, min(56, int(round(min(w, h) * 0.16))))
    inner_left = inset
    inner_top = inset
    inner_right = w - inset
    inner_bottom = h - inset
    if inner_right > inner_left and inner_bottom > inner_top:
        for y in range(inner_top, inner_bottom):
            for x in range(inner_left, inner_right):
                r, g, b, a = px[x, y]
                if a == 0:
                    continue
                px[x, y] = (r, g, b, 0)
    output_path = OUTPUT_DIR / OPTIONAL_STATS_PANEL_FRAME_ONLY_OUTPUT
    panel.save(output_path, "PNG")
    return OPTIONAL_STATS_PANEL_FRAME_ONLY_OUTPUT


def write_report(
    mapping: dict[str, Component],
    source_size: tuple[int, int],
    alpha_minmax: tuple[int, int],
    cleaned_pixel_counts: dict[str, int],
    semantic_outputs: dict[str, str],
    frame_only_output: str,
) -> None:
    payload = {
        "source": str(SOURCE_IMAGE.relative_to(ROOT)).replace("\\", "/"),
        "source_size": list(source_size),
        "source_alpha_minmax": list(alpha_minmax),
        "cleanup": {
            "edge_connected_magenta_spill_removed_pixels": cleaned_pixel_counts,
        },
        "outputs": {
            name: {
                "bbox": list(comp.bbox),
                "pixel_count": comp.pixel_count,
                "mean_luma": round(comp.mean_luma, 4),
                "output": str((OUTPUT_DIR / name).relative_to(ROOT)).replace("\\", "/"),
            }
            for name, comp in sorted(mapping.items())
        },
        "semantic_outputs": {
            source_name: str((OUTPUT_DIR / semantic_name).relative_to(ROOT)).replace("\\", "/")
            for source_name, semantic_name in sorted(semantic_outputs.items())
        },
        "optional_outputs": {
            "stats_panel_frame_only": str((OUTPUT_DIR / frame_only_output).relative_to(ROOT)).replace("\\", "/"),
        },
    }
    REPORT_PATH.write_text(json.dumps(payload, indent=2) + "\n", encoding="utf-8")


def write_preview(mapping: dict[str, Component]) -> None:
    items = sorted(mapping.items())
    pad = 24
    cols = 2
    rows = (len(items) + cols - 1) // cols
    tile_w = 760
    tile_h = 350
    canvas = Image.new("RGBA", (cols * tile_w + (cols + 1) * pad, rows * tile_h + (rows + 1) * pad), (17, 17, 22, 255))
    draw = ImageDraw.Draw(canvas)

    for idx, (name, _) in enumerate(items):
        row = idx // cols
        col = idx % cols
        x0 = pad + col * (tile_w + pad)
        y0 = pad + row * (tile_h + pad)
        tile = Image.open(OUTPUT_DIR / name).convert("RGBA")
        scale = min((tile_w - 32) / tile.width, (tile_h - 64) / tile.height)
        new_w = max(1, int(tile.width * scale))
        new_h = max(1, int(tile.height * scale))
        resized = tile.resize((new_w, new_h), Image.Resampling.LANCZOS)
        px = x0 + (tile_w - new_w) // 2
        py = y0 + 24 + (tile_h - 64 - new_h) // 2
        draw.rectangle((x0, y0, x0 + tile_w, y0 + tile_h), outline=(95, 95, 110, 255), width=2)
        canvas.alpha_composite(resized, (px, py))
        draw.text((x0 + 12, y0 + 8), name, fill=(230, 230, 238, 255))

    PREVIEW_PATH.parent.mkdir(parents=True, exist_ok=True)
    canvas.save(PREVIEW_PATH, "PNG")


def main() -> None:
    if not SOURCE_IMAGE.exists():
        raise SystemExit(f"Source image not found: {SOURCE_IMAGE}")

    image = Image.open(SOURCE_IMAGE).convert("RGBA")
    alpha_minmax = image.getchannel("A").getextrema()
    components = find_components(image)
    mapping = classify_components(components)
    cleaned_pixel_counts = save_crops(image, mapping)
    semantic_outputs = write_semantic_icon_outputs()
    frame_only_output = write_optional_stats_panel_frame_only()
    write_report(mapping, image.size, alpha_minmax, cleaned_pixel_counts, semantic_outputs, frame_only_output)
    write_preview(mapping)
    print(f"Extracted {len(mapping)} menu assets to {OUTPUT_DIR}")
    print(f"Preview: {PREVIEW_PATH}")
    print(f"Report: {REPORT_PATH}")


if __name__ == "__main__":
    main()
